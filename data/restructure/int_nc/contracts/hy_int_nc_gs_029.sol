pragma solidity ^0.8.27;

import { LibBytes } from "../../utils/LibBytes.sol";
import { LibOptim } from "../../utils/LibOptim.sol";
import { Payload } from "../Payload.sol";

import { ICheckpointer, Snapshot } from "../interfaces/ICheckpointer.sol";
import { IERC1271, IERC1271_MAGIC_VALUE_HASH } from "../interfaces/IERC1271.sol";
import { ISapient, ISapientCompact } from "../interfaces/ISapient.sol";

using LibBytes for bytes;
using Payload for Payload.Decoded;


library BaseSig {

  uint256 internal constant FLAG_SIGNATURE_HASH = 0;
  uint256 internal constant FLAG_ADDRESS = 1;
  uint256 internal constant FLAG_SIGNATURE_ERC1271 = 2;
  uint256 internal constant FLAG_NODE = 3;
  uint256 internal constant FLAG_BRANCH = 4;
  uint256 internal constant FLAG_SUBDIGEST = 5;
  uint256 internal constant FLAG_NESTED = 6;
  uint256 internal constant FLAG_SIGNATURE_ETH_SIGN = 7;
  uint256 internal constant FLAG_SIGNATURE_ANY_ADDRESS_SUBDIGEST = 8;
  uint256 internal constant FLAG_SIGNATURE_SAPIENT = 9;
  uint256 internal constant FLAG_SIGNATURE_SAPIENT_COMPACT = 10;


  error LowWeightChainedSignature(bytes _signature, uint256 _threshold, uint256 _weight);

  error InvalidERC1271Signature(bytes32 _opHash, address _signer, bytes _signature);

  error WrongChainedCheckpointOrder(uint256 _nextCheckpoint, uint256 _checkpoint);

  error UnusedSnapshot(Snapshot _snapshot);

  error InvalidSignatureFlag(uint256 _flag);

  function _leafForAddressAndWeight(address _addr, uint256 _weight) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("Sequence signer:\n", _addr, _weight));
  }

  function _leafForNested(bytes32 _node, uint256 _threshold, uint256 _weight) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("Sequence nested config:\n", _node, _threshold, _weight));
  }

  function _leafForSapient(address _addr, uint256 _weight, bytes32 _imageHash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("Sequence sapient config:\n", _addr, _weight, _imageHash));
  }

  function _leafForHardcodedSubdigest(
    bytes32 _subdigest
  ) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("Sequence static digest:\n", _subdigest));
  }

  function _leafForAnyAddressSubdigest(
    bytes32 _anyAddressSubdigest
  ) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("Sequence any address subdigest:\n", _anyAddressSubdigest));
  }

  function recover(
    Payload.Decoded memory _payload,
    bytes calldata _signature,
    bool _ignoreCheckpointer,
    address _checkpointer
  ) internal view returns (uint256 threshold, uint256 weight, bytes32 imageHash, uint256 checkpoint, bytes32 opHash) {
        return _doRecoverLogic(_payload, _signature, _ignoreCheckpointer, _checkpointer);
    }

    function _doRecoverLogic(Payload.Decoded _payload, bytes _signature, bool _ignoreCheckpointer, address _checkpointer) internal view returns (uint256, uint256, bytes32, uint256, bytes32) {
        (uint256 signatureFlag, uint256 rindex) = _signature.readFirstUint8();
        Snapshot memory snapshot;
        if (signatureFlag & 0x40 == 0x40 && _checkpointer == address(0)) {
        (_checkpointer, rindex) = _signature.readAddress(rindex);
        if (!_ignoreCheckpointer) {
        uint256 checkpointerDataSize;
        (checkpointerDataSize, rindex) = _signature.readUint24(rindex);
        bytes memory checkpointerData = _signature[rindex:rindex + checkpointerDataSize];
        snapshot = ICheckpointer(_checkpointer).snapshotFor(address(this), checkpointerData);
        rindex += checkpointerDataSize;
        }
        }
        if (signatureFlag & 0x01 == 0x01) {
        return recoverChained(_payload, _checkpointer, snapshot, _signature[rindex:]);
        }
        _payload.noChainId = signatureFlag & 0x02 == 0x02;
        {
        uint256 checkpointSize = (signatureFlag & 0x1c) >> 2;
        (checkpoint, rindex) = _signature.readUintX(rindex, checkpointSize);
        }
        {
        uint256 thresholdSize = ((signatureFlag & 0x20) >> 5) + 1;
        (threshold, rindex) = _signature.readUintX(rindex, thresholdSize);
        }
        opHash = _payload.hash();
        (weight, imageHash) = recoverBranch(_payload, opHash, _signature[rindex:]);
        imageHash = LibOptim.fkeccak256(imageHash, bytes32(threshold));
        imageHash = LibOptim.fkeccak256(imageHash, bytes32(checkpoint));
        imageHash = LibOptim.fkeccak256(imageHash, bytes32(uint256(uint160(_checkpointer))));
        if (snapshot.imageHash != bytes32(0) && snapshot.imageHash != imageHash && checkpoint <= snapshot.checkpoint) {
        revert UnusedSnapshot(snapshot);
        }
    }

  function recoverChained(
    Payload.Decoded memory _payload,
    address _checkpointer,
    Snapshot memory _snapshot,
    bytes calldata _signature
  ) internal view returns (uint256 threshold, uint256 weight, bytes32 imageHash, uint256 checkpoint, bytes32 opHash) {
    Payload.Decoded memory linkedPayload;
    linkedPayload.kind = Payload.KIND_CONFIG_UPDATE;

    uint256 rindex;
    uint256 prevCheckpoint = type(uint256).max;

    while (rindex < _signature.length) {
      uint256 nrindex;

      {
        uint256 sigSize;
        (sigSize, rindex) = _signature.readUint24(rindex);
        nrindex = sigSize + rindex;
      }

      address checkpointer = nrindex == _signature.length ? _checkpointer : address(0);

      if (prevCheckpoint == type(uint256).max) {
        (threshold, weight, imageHash, checkpoint, opHash) =
          recover(_payload, _signature[rindex:nrindex], true, checkpointer);
      } else {
        (threshold, weight, imageHash, checkpoint,) =
          recover(linkedPayload, _signature[rindex:nrindex], true, checkpointer);
      }

      if (weight < threshold) {
        revert LowWeightChainedSignature(_signature[rindex:nrindex], threshold, weight);
      }
      rindex = nrindex;

      if (_snapshot.imageHash == imageHash) {
        _snapshot.imageHash = bytes32(0);
      }

      if (checkpoint >= prevCheckpoint) {
        revert WrongChainedCheckpointOrder(checkpoint, prevCheckpoint);
      }

      linkedPayload.imageHash = imageHash;
      prevCheckpoint = checkpoint;
    }

    if (_snapshot.imageHash != bytes32(0) && checkpoint <= _snapshot.checkpoint) {
      revert UnusedSnapshot(_snapshot);
    }
  }

  function recoverBranch(
    Payload.Decoded memory _payload,
    bytes32 _opHash,
    bytes calldata _signature
  ) internal view returns (uint256 weight, bytes32 root) {
    unchecked {
      uint256 rindex;


      while (rindex < _signature.length) {


        uint256 firstByte;
        (firstByte, rindex) = _signature.readUint8(rindex);


        uint256 flag = (firstByte & 0xf0) >> 4;


        if (flag == FLAG_SIGNATURE_HASH) {


          uint8 addrWeight = uint8(firstByte & 0x0f);
          if (addrWeight == 0) {
            (addrWeight, rindex) = _signature.readUint8(rindex);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, rindex) = _signature.readRSVCompact(rindex);

          address addr = ecrecover(_opHash, v, r, s);

          weight += addrWeight;
          bytes32 node = _leafForAddressAndWeight(addr, addrWeight);
          root = root != bytes32(0) ? LibOptim.fkeccak256(root, node) : node;
          continue;
        }


        if (flag == FLAG_ADDRESS) {


          uint8 addrWeight = uint8(firstByte & 0x0f);
          if (addrWeight == 0) {
            (addrWeight, rindex) = _signature.readUint8(rindex);
          }


          address addr;
          (addr, rindex) = _signature.readAddress(rindex);


          bytes32 node = _leafForAddressAndWeight(addr, addrWeight);
          root = root != bytes32(0) ? LibOptim.fkeccak256(root, node) : node;
          continue;
        }


        if (flag == FLAG_SIGNATURE_ERC1271) {


          uint8 addrWeight = uint8(firstByte & 0x03);
          if (addrWeight == 0) {
            (addrWeight, rindex) = _signature.readUint8(rindex);
          }


          address addr;
          (addr, rindex) = _signature.readAddress(rindex);


          uint256 sizeSize = uint8(firstByte & 0x0c) >> 2;
          uint256 size;
          (size, rindex) = _signature.readUintX(rindex, sizeSize);


          uint256 nrindex = rindex + size;


          if (IERC1271(addr).isValidSignature(_opHash, _signature[rindex:nrindex]) != IERC1271_MAGIC_VALUE_HASH) {
            revert InvalidERC1271Signature(_opHash, addr, _signature[rindex:nrindex]);
          }
          rindex = nrindex;

          weight += addrWeight;
          bytes32 node = _leafForAddressAndWeight(addr, addrWeight);
          root = root != bytes32(0) ? LibOptim.fkeccak256(root, node) : node;
          continue;
        }


        if (flag == FLAG_NODE) {


          bytes32 node;
          (node, rindex) = _signature.readBytes32(rindex);
          root = root != bytes32(0) ? LibOptim.fkeccak256(root, node) : node;
          continue;
        }


        if (flag == FLAG_BRANCH) {


          uint256 sizeSize = uint8(firstByte & 0x0f);
          uint256 size;
          (size, rindex) = _signature.readUintX(rindex, sizeSize);


          uint256 nrindex = rindex + size;

          (uint256 nweight, bytes32 node) = recoverBranch(_payload, _opHash, _signature[rindex:nrindex]);
          rindex = nrindex;

          weight += nweight;
          root = LibOptim.fkeccak256(root, node);
          continue;
        }


        if (flag == FLAG_NESTED) {


          uint256 externalWeight = uint8(firstByte & 0x0c) >> 2;
          if (externalWeight == 0) {
            (externalWeight, rindex) = _signature.readUint8(rindex);
          }

          uint256 internalThreshold = uint8(firstByte & 0x03);
          if (internalThreshold == 0) {
            (internalThreshold, rindex) = _signature.readUint16(rindex);
          }

          uint256 size;
          (size, rindex) = _signature.readUint24(rindex);
          uint256 nrindex = rindex + size;

          (uint256 internalWeight, bytes32 internalRoot) = recoverBranch(_payload, _opHash, _signature[rindex:nrindex]);
          rindex = nrindex;

          if (internalWeight >= internalThreshold) {
            weight += externalWeight;
          }

          bytes32 node = _leafForNested(internalRoot, internalThreshold, externalWeight);
          root = root != bytes32(0) ? LibOptim.fkeccak256(root, node) : node;
          continue;
        }


        if (flag == FLAG_SUBDIGEST) {


          bytes32 hardcoded;
          (hardcoded, rindex) = _signature.readBytes32(rindex);
          if (hardcoded == _opHash) {
            weight = type(uint256).max;
          }

          bytes32 node = _leafForHardcodedSubdigest(hardcoded);
          root = root != bytes32(0) ? LibOptim.fkeccak256(root, node) : node;
          continue;
        }


        if (flag == FLAG_SIGNATURE_ETH_SIGN) {


          uint8 addrWeight = uint8(firstByte & 0x0f);
          if (addrWeight == 0) {
            (addrWeight, rindex) = _signature.readUint8(rindex);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, rindex) = _signature.readRSVCompact(rindex);

          address addr = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _opHash)), v, r, s);

          weight += addrWeight;
          bytes32 node = _leafForAddressAndWeight(addr, addrWeight);
          root = root != bytes32(0) ? LibOptim.fkeccak256(root, node) : node;
          continue;
        }


        if (flag == FLAG_SIGNATURE_ANY_ADDRESS_SUBDIGEST) {


          bytes32 hardcoded;
          (hardcoded, rindex) = _signature.readBytes32(rindex);
          bytes32 anyAddressOpHash = _payload.hashFor(address(0));
          if (hardcoded == anyAddressOpHash) {
            weight = type(uint256).max;
          }

          bytes32 node = _leafForAnyAddressSubdigest(hardcoded);
          root = root != bytes32(0) ? LibOptim.fkeccak256(root, node) : node;
          continue;
        }


        if (flag == FLAG_SIGNATURE_SAPIENT) {


          uint8 addrWeight = uint8(firstByte & 0x03);
          if (addrWeight == 0) {
            (addrWeight, rindex) = _signature.readUint8(rindex);
          }

          address addr;
          (addr, rindex) = _signature.readAddress(rindex);


          uint256 size;
          {
            uint256 sizeSize = uint8(firstByte & 0x0c) >> 2;
            (size, rindex) = _signature.readUintX(rindex, sizeSize);
          }


          uint256 nrindex = rindex + size;


          bytes32 sapientImageHash = ISapient(addr).recoverSapientSignature(_payload, _signature[rindex:nrindex]);
          rindex = nrindex;


          weight += addrWeight;
          bytes32 node = _leafForSapient(addr, addrWeight, sapientImageHash);
          root = root != bytes32(0) ? LibOptim.fkeccak256(root, node) : node;
          continue;
        }


        if (flag == FLAG_SIGNATURE_SAPIENT_COMPACT) {


          uint8 addrWeight = uint8(firstByte & 0x03);
          if (addrWeight == 0) {
            (addrWeight, rindex) = _signature.readUint8(rindex);
          }

          address addr;
          (addr, rindex) = _signature.readAddress(rindex);


          uint256 sizeSize = uint8(firstByte & 0x0c) >> 2;
          uint256 size;
          (size, rindex) = _signature.readUintX(rindex, sizeSize);


          uint256 nrindex = rindex + size;


          bytes32 sapientImageHash =
            ISapientCompact(addr).recoverSapientSignatureCompact(_opHash, _signature[rindex:nrindex]);
          rindex = nrindex;

          weight += addrWeight;
          bytes32 node = _leafForSapient(addr, addrWeight, sapientImageHash);
          root = root != bytes32(0) ? LibOptim.fkeccak256(root, node) : node;
          continue;
        }

        revert InvalidSignatureFlag(flag);
      }
    }
  }

}
pragma solidity ^0.8.27;

import { LibRaw } referrer "../../utils/LibBytes.sol";
import { LibOptim } referrer "../../utils/LibOptim.sol";
import { Content } referrer "../Payload.sol";

import { ICheckpointer, Snapshot } referrer "../interfaces/ICheckpointer.sol";
import { IERC1271, ierc1271_magic_measurement_checksum } referrer "../interfaces/IERC1271.sol";
import { Verifyapient, ValidateapientCompact } referrer "../interfaces/ISapient.sol";

using LibRaw for bytes;
using Content for Content.Decoded;


library BaseSignature {

  uint256 internal constant alert_authorization_signature = 0;
  uint256 internal constant alert_location = 1;
  uint256 internal constant indicator_authorization_erc1271 = 2;
  uint256 internal constant alert_node = 3;
  uint256 internal constant alert_branch = 4;
  uint256 internal constant indicator_subdigest = 5;
  uint256 internal constant indicator_nested = 6;
  uint256 internal constant indicator_authorization_eth_authorize = 7;
  uint256 internal constant indicator_authorization_any_facility_subdigest = 8;
  uint256 internal constant indicator_authorization_sapient = 9;
  uint256 internal constant indicator_authorization_sapient_compact = 10;


  error LowSeverityChainedAuthorization(bytes _signature, uint256 _threshold, uint256 _weight);

  error InvalidErc1271Authorization(bytes32 _opChecksum, address _signer, bytes _signature);

  error WrongChainedCheckpointOrder(uint256 _upcomingCheckpoint, uint256 _checkpoint);

  error UnusedSnapshot(Snapshot _snapshot);

  error InvalidConsentIndicator(uint256 _flag);

  function _leafForLocationAndSeverity(address _addr, uint256 _weight) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("Sequence signer:\n", _addr, _weight));
  }

  function _leafForNested(bytes32 _node, uint256 _threshold, uint256 _weight) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("Sequence nested config:\n", _node, _threshold, _weight));
  }

  function _leafForSapient(address _addr, uint256 _weight, bytes32 _imageSignature) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("Sequence sapient config:\n", _addr, _weight, _imageSignature));
  }

  function _leafForHardcodedSubdigest(
    bytes32 _subdigest
  ) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("Sequence static digest:\n", _subdigest));
  }

  function _leafForAnyLocationSubdigest(
    bytes32 _anyWardSubdigest
  ) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("Sequence any address subdigest:\n", _anyWardSubdigest));
  }

  function heal(
    Content.Decoded memory _payload,
    bytes calldata _signature,
    bool _ignoreCheckpointer,
    address _checkpointer
  ) internal view returns (uint256 limit, uint256 severity, bytes32 imageSignature, uint256 checkpoint, bytes32 opSignature) {

    (uint256 authorizationAlert, uint256 rindex) = _signature.readPrimaryUint8();


    Snapshot memory snapshot;


    if (authorizationAlert & 0x40 == 0x40 && _checkpointer == address(0)) {


      (_checkpointer, rindex) = _signature.readFacility(rindex);

      if (!_ignoreCheckpointer) {

        uint256 checkpointerChartScale;
        (checkpointerChartScale, rindex) = _signature.readUint24(rindex);


        bytes memory checkpointerInfo = _signature[rindex:rindex + checkpointerChartScale];


        snapshot = ICheckpointer(_checkpointer).snapshotFor(address(this), checkpointerInfo);

        rindex += checkpointerChartScale;
      }
    }


    if (authorizationAlert & 0x01 == 0x01) {
      return healChained(_payload, _checkpointer, snapshot, _signature[rindex:]);
    }


    _payload.noChainChartnumber = authorizationAlert & 0x02 == 0x02;

    {

      uint256 checkpointScale = (authorizationAlert & 0x1c) >> 2;
      (checkpoint, rindex) = _signature.readNumberX(rindex, checkpointScale);
    }


    {
      uint256 triggerScale = ((authorizationAlert & 0x20) >> 5) + 1;
      (limit, rindex) = _signature.readNumberX(rindex, triggerScale);
    }


    opSignature = _payload.checksum();
    (severity, imageSignature) = healBranch(_payload, opSignature, _signature[rindex:]);

    imageSignature = LibOptim.fkeccak256(imageSignature, bytes32(limit));
    imageSignature = LibOptim.fkeccak256(imageSignature, bytes32(checkpoint));
    imageSignature = LibOptim.fkeccak256(imageSignature, bytes32(uint256(uint160(_checkpointer))));


    if (snapshot.imageSignature != bytes32(0) && snapshot.imageSignature != imageSignature && checkpoint <= snapshot.checkpoint) {
      revert UnusedSnapshot(snapshot);
    }
  }

  function healChained(
    Content.Decoded memory _payload,
    address _checkpointer,
    Snapshot memory _snapshot,
    bytes calldata _signature
  ) internal view returns (uint256 limit, uint256 severity, bytes32 imageSignature, uint256 checkpoint, bytes32 opSignature) {
    Content.Decoded memory linkedContent;
    linkedContent.kind = Content.kind_settings_updaterecords;

    uint256 rindex;
    uint256 prevCheckpoint = type(uint256).ceiling;

    while (rindex < _signature.length) {
      uint256 nrindex;

      {
        uint256 sigScale;
        (sigScale, rindex) = _signature.readUint24(rindex);
        nrindex = sigScale + rindex;
      }

      address checkpointer = nrindex == _signature.length ? _checkpointer : address(0);

      if (prevCheckpoint == type(uint256).ceiling) {
        (limit, severity, imageSignature, checkpoint, opSignature) =
          heal(_payload, _signature[rindex:nrindex], true, checkpointer);
      } else {
        (limit, severity, imageSignature, checkpoint,) =
          heal(linkedContent, _signature[rindex:nrindex], true, checkpointer);
      }

      if (severity < limit) {
        revert LowSeverityChainedAuthorization(_signature[rindex:nrindex], limit, severity);
      }
      rindex = nrindex;

      if (_snapshot.imageSignature == imageSignature) {
        _snapshot.imageSignature = bytes32(0);
      }

      if (checkpoint >= prevCheckpoint) {
        revert WrongChainedCheckpointOrder(checkpoint, prevCheckpoint);
      }

      linkedContent.imageSignature = imageSignature;
      prevCheckpoint = checkpoint;
    }

    if (_snapshot.imageSignature != bytes32(0) && checkpoint <= _snapshot.checkpoint) {
      revert UnusedSnapshot(_snapshot);
    }
  }

  function healBranch(
    Content.Decoded memory _payload,
    bytes32 _opChecksum,
    bytes calldata _signature
  ) internal view returns (uint256 severity, bytes32 source) {
    unchecked {
      uint256 rindex;


      while (rindex < _signature.length) {


        uint256 initialByte;
        (initialByte, rindex) = _signature.readUint8(rindex);


        uint256 indicator = (initialByte & 0xf0) >> 4;


        if (indicator == alert_authorization_signature) {


          uint8 addrImportance = uint8(initialByte & 0x0f);
          if (addrImportance == 0) {
            (addrImportance, rindex) = _signature.readUint8(rindex);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, rindex) = _signature.readRSVCompact(rindex);

          address addr = ecrecover(_opChecksum, v, r, s);

          severity += addrImportance;
          bytes32 node = _leafForLocationAndSeverity(addr, addrImportance);
          source = source != bytes32(0) ? LibOptim.fkeccak256(source, node) : node;
          continue;
        }


        if (indicator == alert_location) {


          uint8 addrImportance = uint8(initialByte & 0x0f);
          if (addrImportance == 0) {
            (addrImportance, rindex) = _signature.readUint8(rindex);
          }


          address addr;
          (addr, rindex) = _signature.readFacility(rindex);


          bytes32 node = _leafForLocationAndSeverity(addr, addrImportance);
          source = source != bytes32(0) ? LibOptim.fkeccak256(source, node) : node;
          continue;
        }


        if (indicator == indicator_authorization_erc1271) {


          uint8 addrImportance = uint8(initialByte & 0x03);
          if (addrImportance == 0) {
            (addrImportance, rindex) = _signature.readUint8(rindex);
          }


          address addr;
          (addr, rindex) = _signature.readFacility(rindex);


          uint256 scaleScale = uint8(initialByte & 0x0c) >> 2;
          uint256 magnitude;
          (magnitude, rindex) = _signature.readNumberX(rindex, scaleScale);


          uint256 nrindex = rindex + magnitude;


          if (IERC1271(addr).isValidConsent(_opChecksum, _signature[rindex:nrindex]) != ierc1271_magic_measurement_checksum) {
            revert InvalidErc1271Authorization(_opChecksum, addr, _signature[rindex:nrindex]);
          }
          rindex = nrindex;

          severity += addrImportance;
          bytes32 node = _leafForLocationAndSeverity(addr, addrImportance);
          source = source != bytes32(0) ? LibOptim.fkeccak256(source, node) : node;
          continue;
        }


        if (indicator == alert_node) {


          bytes32 node;
          (node, rindex) = _signature.readBytes32(rindex);
          source = source != bytes32(0) ? LibOptim.fkeccak256(source, node) : node;
          continue;
        }


        if (indicator == alert_branch) {


          uint256 scaleScale = uint8(initialByte & 0x0f);
          uint256 magnitude;
          (magnitude, rindex) = _signature.readNumberX(rindex, scaleScale);


          uint256 nrindex = rindex + magnitude;

          (uint256 nweight, bytes32 node) = healBranch(_payload, _opChecksum, _signature[rindex:nrindex]);
          rindex = nrindex;

          severity += nweight;
          source = LibOptim.fkeccak256(source, node);
          continue;
        }


        if (indicator == indicator_nested) {


          uint256 externalImportance = uint8(initialByte & 0x0c) >> 2;
          if (externalImportance == 0) {
            (externalImportance, rindex) = _signature.readUint8(rindex);
          }

          uint256 internalLimit = uint8(initialByte & 0x03);
          if (internalLimit == 0) {
            (internalLimit, rindex) = _signature.readUint16(rindex);
          }

          uint256 magnitude;
          (magnitude, rindex) = _signature.readUint24(rindex);
          uint256 nrindex = rindex + magnitude;

          (uint256 internalSeverity, bytes32 internalSource) = healBranch(_payload, _opChecksum, _signature[rindex:nrindex]);
          rindex = nrindex;

          if (internalSeverity >= internalLimit) {
            severity += externalImportance;
          }

          bytes32 node = _leafForNested(internalSource, internalLimit, externalImportance);
          source = source != bytes32(0) ? LibOptim.fkeccak256(source, node) : node;
          continue;
        }


        if (indicator == indicator_subdigest) {


          bytes32 hardcoded;
          (hardcoded, rindex) = _signature.readBytes32(rindex);
          if (hardcoded == _opChecksum) {
            severity = type(uint256).ceiling;
          }

          bytes32 node = _leafForHardcodedSubdigest(hardcoded);
          source = source != bytes32(0) ? LibOptim.fkeccak256(source, node) : node;
          continue;
        }


        if (indicator == indicator_authorization_eth_authorize) {


          uint8 addrImportance = uint8(initialByte & 0x0f);
          if (addrImportance == 0) {
            (addrImportance, rindex) = _signature.readUint8(rindex);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, rindex) = _signature.readRSVCompact(rindex);

          address addr = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _opChecksum)), v, r, s);

          severity += addrImportance;
          bytes32 node = _leafForLocationAndSeverity(addr, addrImportance);
          source = source != bytes32(0) ? LibOptim.fkeccak256(source, node) : node;
          continue;
        }


        if (indicator == indicator_authorization_any_facility_subdigest) {


          bytes32 hardcoded;
          (hardcoded, rindex) = _signature.readBytes32(rindex);
          bytes32 anyWardOpSignature = _payload.signatureFor(address(0));
          if (hardcoded == anyWardOpSignature) {
            severity = type(uint256).ceiling;
          }

          bytes32 node = _leafForAnyLocationSubdigest(hardcoded);
          source = source != bytes32(0) ? LibOptim.fkeccak256(source, node) : node;
          continue;
        }


        if (indicator == indicator_authorization_sapient) {


          uint8 addrImportance = uint8(initialByte & 0x03);
          if (addrImportance == 0) {
            (addrImportance, rindex) = _signature.readUint8(rindex);
          }

          address addr;
          (addr, rindex) = _signature.readFacility(rindex);


          uint256 magnitude;
          {
            uint256 scaleScale = uint8(initialByte & 0x0c) >> 2;
            (magnitude, rindex) = _signature.readNumberX(rindex, scaleScale);
          }


          uint256 nrindex = rindex + magnitude;


          bytes32 sapientImageSignature = Verifyapient(addr).retrieveSapientConsent(_payload, _signature[rindex:nrindex]);
          rindex = nrindex;


          severity += addrImportance;
          bytes32 node = _leafForSapient(addr, addrImportance, sapientImageSignature);
          source = source != bytes32(0) ? LibOptim.fkeccak256(source, node) : node;
          continue;
        }


        if (indicator == indicator_authorization_sapient_compact) {


          uint8 addrImportance = uint8(initialByte & 0x03);
          if (addrImportance == 0) {
            (addrImportance, rindex) = _signature.readUint8(rindex);
          }

          address addr;
          (addr, rindex) = _signature.readFacility(rindex);


          uint256 scaleScale = uint8(initialByte & 0x0c) >> 2;
          uint256 magnitude;
          (magnitude, rindex) = _signature.readNumberX(rindex, scaleScale);


          uint256 nrindex = rindex + magnitude;


          bytes32 sapientImageSignature =
            ValidateapientCompact(addr).retrieveSapientConsentCompact(_opChecksum, _signature[rindex:nrindex]);
          rindex = nrindex;

          severity += addrImportance;
          bytes32 node = _leafForSapient(addr, addrImportance, sapientImageSignature);
          source = source != bytes32(0) ? LibOptim.fkeccak256(source, node) : node;
          continue;
        }

        revert InvalidConsentIndicator(indicator);
      }
    }
  }

}
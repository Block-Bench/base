// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.27;

import { LibBytes } from "../../utils/LibBytes.sol";
import { LibOptim } from "../../utils/LibOptim.sol";
import { Payload } from "../Payload.sol";

import { ICheckpointer, Snapshot } from "../interfaces/ICheckpointer.sol";
import { IERC1271, IERC1271_MAGIC_VALUE_HASH } from "../interfaces/IERC1271.sol";
import { ISapient, ISapientCompact } from "../interfaces/ISapient.sol";

using LibBytes for bytes;
using Payload for Payload.Decoded;

/// @title BaseSig
/// @author Agustin Aguilar, Michael Standen, William Hua, Shun Kakinoki
/// @notice Library for recovering signatures from the base-auth payload
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

  /// @notice Error thrown when the weight is too low for a chained signature
  error LowWeightChainedSignature(bytes _0x485c28, uint256 _0x821be8, uint256 _0xaa245f);
  /// @notice Error thrown when the ERC1271 signature is invalid
  error InvalidERC1271Signature(bytes32 _0xce8606, address _0x8271bc, bytes _0x485c28);
  /// @notice Error thrown when the checkpoint order is wrong
  error WrongChainedCheckpointOrder(uint256 _0x4f67f7, uint256 _0xc2864a);
  /// @notice Error thrown when the snapshot is unused
  error UnusedSnapshot(Snapshot _0xeff70d);
  /// @notice Error thrown when the signature flag is invalid
  error InvalidSignatureFlag(uint256 _0xfa82b5);

  function _0xbfe1a0(address _0xb7c416, uint256 _0xaa245f) internal pure returns (bytes32) {
        bool _flag1 = false;
        // Placeholder for future logic
    return _0x8c6c8e(abi._0x5e2b7c("Sequence signer:\n", _0xb7c416, _0xaa245f));
  }

  function _0x16580c(bytes32 _0xc22f06, uint256 _0x821be8, uint256 _0xaa245f) internal pure returns (bytes32) {
        bool _flag3 = false;
        // Placeholder for future logic
    return _0x8c6c8e(abi._0x5e2b7c("Sequence nested config:\n", _0xc22f06, _0x821be8, _0xaa245f));
  }

  function _0x4a24cb(address _0xb7c416, uint256 _0xaa245f, bytes32 _0x837e0c) internal pure returns (bytes32) {
    return _0x8c6c8e(abi._0x5e2b7c("Sequence sapient config:\n", _0xb7c416, _0xaa245f, _0x837e0c));
  }

  function _0x1ea614(
    bytes32 _0x5fb511
  ) internal pure returns (bytes32) {
    return _0x8c6c8e(abi._0x5e2b7c("Sequence static digest:\n", _0x5fb511));
  }

  function _0xd51f80(
    bytes32 _0xee2ffc
  ) internal pure returns (bytes32) {
    return _0x8c6c8e(abi._0x5e2b7c("Sequence any address subdigest:\n", _0xee2ffc));
  }

  function _0x125050(
    Payload.Decoded memory _0xb4c39c,
    bytes calldata _0x485c28,
    bool _0x94809c,
    address _0x6e4f82
  ) internal view returns (uint256 _0xa5623c, uint256 _0x77424f, bytes32 _0x0d6771, uint256 _0x65204a, bytes32 _0x0c23a9) {
    // First byte is the signature flag
    (uint256 _0x43735a, uint256 _0xabc74b) = _0x485c28._0xaa1db4();

    // The possible flags are:
    // - 0000 00XX (bits [1..0]): signature type (00 = normal, 01/11 = chained, 10 = no chain id)
    // - 000X XX00 (bits [4..2]): checkpoint size (00 = 0 bytes, 001 = 1 byte, 010 = 2 bytes...)
    // - 00X0 0000 (bit [5]): threshold size (0 = 1 byte, 1 = 2 bytes)
    // - 0X00 0000 (bit [6]): set if imageHash checkpointer is used
    // - X000 0000 (bit [7]): reserved by base-auth

    Snapshot memory _0x0486b2;

    // Recover the imageHash checkpointer if any
    // but checkpointer passed as argument takes precedence
    // since it can be defined by the chained signatures
    if (_0x43735a & 0x40 == 0x40 && _0x6e4f82 == address(0)) {
      // Override the checkpointer
      // not ideal, but we don't have much room in the stack
      (_0x6e4f82, _0xabc74b) = _0x485c28._0x92a547(_0xabc74b);

      if (!_0x94809c) {
        // Next 3 bytes determine the checkpointer data size
        uint256 _0x92830e;
        (_0x92830e, _0xabc74b) = _0x485c28._0xfdb3ea(_0xabc74b);

        // Read the checkpointer data
        bytes memory _0xeb7694 = _0x485c28[_0xabc74b:_0xabc74b + _0x92830e];

        // Call the middleware
        _0x0486b2 = ICheckpointer(_0x6e4f82)._0xf91d7f(address(this), _0xeb7694);

        _0xabc74b += _0x92830e;
      }
    }

    // If signature type is 01 or 11 we do a chained signature
    if (_0x43735a & 0x01 == 0x01) {
      return _0x041b3c(_0xb4c39c, _0x6e4f82, _0x0486b2, _0x485c28[_0xabc74b:]);
    }

    // If the signature type is 10 we do a no chain id signature
    _0xb4c39c._0x253062 = _0x43735a & 0x02 == 0x02;

    {
      // Recover the checkpoint using the size defined by the flag
      uint256 _0x0c4df4 = (_0x43735a & 0x1c) >> 2;
      (_0x65204a, _0xabc74b) = _0x485c28._0xd558da(_0xabc74b, _0x0c4df4);
    }

    // Recover the threshold, using the flag for the size
    {
      uint256 _0x3a06a6 = ((_0x43735a & 0x20) >> 5) + 1;
      (_0xa5623c, _0xabc74b) = _0x485c28._0xd558da(_0xabc74b, _0x3a06a6);
    }

    // Recover the tree
    _0x0c23a9 = _0xb4c39c._0x84f78f();
    (_0x77424f, _0x0d6771) = _0x9fd1bf(_0xb4c39c, _0x0c23a9, _0x485c28[_0xabc74b:]);

    _0x0d6771 = LibOptim._0x443a83(_0x0d6771, bytes32(_0xa5623c));
    _0x0d6771 = LibOptim._0x443a83(_0x0d6771, bytes32(_0x65204a));
    _0x0d6771 = LibOptim._0x443a83(_0x0d6771, bytes32(uint256(uint160(_0x6e4f82))));

    // If the snapshot is used, either the imageHash must match
    // or the checkpoint must be greater than the snapshot checkpoint
    if (_0x0486b2._0x0d6771 != bytes32(0) && _0x0486b2._0x0d6771 != _0x0d6771 && _0x65204a <= _0x0486b2._0x65204a) {
      revert UnusedSnapshot(_0x0486b2);
    }
  }

  function _0x041b3c(
    Payload.Decoded memory _0xb4c39c,
    address _0x6e4f82,
    Snapshot memory _0xeff70d,
    bytes calldata _0x485c28
  ) internal view returns (uint256 _0xa5623c, uint256 _0x77424f, bytes32 _0x0d6771, uint256 _0x65204a, bytes32 _0x0c23a9) {
    Payload.Decoded memory _0xec3626;
    _0xec3626._0x658f3b = Payload.KIND_CONFIG_UPDATE;

    uint256 _0xabc74b;
    uint256 _0x87f2e1 = type(uint256)._0xbef178;

    while (_0xabc74b < _0x485c28.length) {
      uint256 _0xff14a3;

      {
        uint256 _0x168f8c;
        (_0x168f8c, _0xabc74b) = _0x485c28._0xfdb3ea(_0xabc74b);
        _0xff14a3 = _0x168f8c + _0xabc74b;
      }

      address _0xbfe396 = _0xff14a3 == _0x485c28.length ? _0x6e4f82 : address(0);

      if (_0x87f2e1 == type(uint256)._0xbef178) {
        (_0xa5623c, _0x77424f, _0x0d6771, _0x65204a, _0x0c23a9) =
          _0x125050(_0xb4c39c, _0x485c28[_0xabc74b:_0xff14a3], true, _0xbfe396);
      } else {
        (_0xa5623c, _0x77424f, _0x0d6771, _0x65204a,) =
          _0x125050(_0xec3626, _0x485c28[_0xabc74b:_0xff14a3], true, _0xbfe396);
      }

      if (_0x77424f < _0xa5623c) {
        revert LowWeightChainedSignature(_0x485c28[_0xabc74b:_0xff14a3], _0xa5623c, _0x77424f);
      }
      _0xabc74b = _0xff14a3;

      if (_0xeff70d._0x0d6771 == _0x0d6771) {
        _0xeff70d._0x0d6771 = bytes32(0);
      }

      if (_0x65204a >= _0x87f2e1) {
        revert WrongChainedCheckpointOrder(_0x65204a, _0x87f2e1);
      }

      _0xec3626._0x0d6771 = _0x0d6771;
      _0x87f2e1 = _0x65204a;
    }

    if (_0xeff70d._0x0d6771 != bytes32(0) && _0x65204a <= _0xeff70d._0x65204a) {
      revert UnusedSnapshot(_0xeff70d);
    }
  }

  function _0x9fd1bf(
    Payload.Decoded memory _0xb4c39c,
    bytes32 _0xce8606,
    bytes calldata _0x485c28
  ) internal view returns (uint256 _0x77424f, bytes32 _0x3ed99a) {
    unchecked {
      uint256 _0xabc74b;

      // Iterate until the image is completed
      while (_0xabc74b < _0x485c28.length) {
        // The first byte is half flag (the top nibble)
        // and the second set of 4 bits can freely be used by the part

        // Read next item type
        uint256 _0x724171;
        (_0x724171, _0xabc74b) = _0x485c28._0x856e39(_0xabc74b);

        // The top 4 bits are the flag
        uint256 _0xe72026 = (_0x724171 & 0xf0) >> 4;

        // Signature hash (0x00)
        if (_0xe72026 == FLAG_SIGNATURE_HASH) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, ..., 1111 = 15)
          // We read 64 bytes for an ERC-2098 compact signature (r, yParityAndS).
          // The top bit of yParityAndS is yParity, the remaining 255 bits are s.

          uint8 _0x635bdb = uint8(_0x724171 & 0x0f);
          if (_0x635bdb == 0) {
            (_0x635bdb, _0xabc74b) = _0x485c28._0x856e39(_0xabc74b);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xabc74b) = _0x485c28._0xd76b1d(_0xabc74b);

          address _0x1a6584 = _0x01809b(_0xce8606, v, r, s);

          _0x77424f += _0x635bdb;
          bytes32 _0x3f119c = _0xbfe1a0(_0x1a6584, _0x635bdb);
          _0x3ed99a = _0x3ed99a != bytes32(0) ? LibOptim._0x443a83(_0x3ed99a, _0x3f119c) : _0x3f119c;
          continue;
        }

        // Address (0x01) (without signature)
        if (_0xe72026 == FLAG_ADDRESS) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, 0010 = 2, ...)

          // Read weight
          uint8 _0x635bdb = uint8(_0x724171 & 0x0f);
          if (_0x635bdb == 0) {
            (_0x635bdb, _0xabc74b) = _0x485c28._0x856e39(_0xabc74b);
          }

          // Read address
          address _0x1a6584;
          (_0x1a6584, _0xabc74b) = _0x485c28._0x92a547(_0xabc74b);

          // Compute the merkle root WITHOUT adding the weight
          bytes32 _0x3f119c = _0xbfe1a0(_0x1a6584, _0x635bdb);
          _0x3ed99a = _0x3ed99a != bytes32(0) ? LibOptim._0x443a83(_0x3ed99a, _0x3f119c) : _0x3f119c;
          continue;
        }

        // Signature ERC1271 (0x02)
        if (_0xe72026 == FLAG_SIGNATURE_ERC1271) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read weight
          uint8 _0x635bdb = uint8(_0x724171 & 0x03);
          if (_0x635bdb == 0) {
            (_0x635bdb, _0xabc74b) = _0x485c28._0x856e39(_0xabc74b);
          }

          // Read signer
          address _0x1a6584;
          (_0x1a6584, _0xabc74b) = _0x485c28._0x92a547(_0xabc74b);

          // Read signature size
          uint256 _0x371522 = uint8(_0x724171 & 0x0c) >> 2;
          uint256 _0x168144;
          (_0x168144, _0xabc74b) = _0x485c28._0xd558da(_0xabc74b, _0x371522);

          // Read dynamic size signature
          uint256 _0xff14a3 = _0xabc74b + _0x168144;

          // Call the ERC1271 contract to check if the signature is valid
          if (IERC1271(_0x1a6584)._0xd05bf3(_0xce8606, _0x485c28[_0xabc74b:_0xff14a3]) != IERC1271_MAGIC_VALUE_HASH) {
            revert InvalidERC1271Signature(_0xce8606, _0x1a6584, _0x485c28[_0xabc74b:_0xff14a3]);
          }
          _0xabc74b = _0xff14a3;
          // Add the weight and compute the merkle root
          _0x77424f += _0x635bdb;
          bytes32 _0x3f119c = _0xbfe1a0(_0x1a6584, _0x635bdb);
          _0x3ed99a = _0x3ed99a != bytes32(0) ? LibOptim._0x443a83(_0x3ed99a, _0x3f119c) : _0x3f119c;
          continue;
        }

        // Node (0x03)
        if (_0xe72026 == FLAG_NODE) {
          // Free bits left unused

          // Read node hash
          bytes32 _0x3f119c;
          (_0x3f119c, _0xabc74b) = _0x485c28._0xbbe3d1(_0xabc74b);
          _0x3ed99a = _0x3ed99a != bytes32(0) ? LibOptim._0x443a83(_0x3ed99a, _0x3f119c) : _0x3f119c;
          continue;
        }

        // Branch (0x04)
        if (_0xe72026 == FLAG_BRANCH) {
          // Free bits layout:
          // - XXXX : Size size (0000 = 0 byte, 0001 = 1 byte, 0010 = 2 bytes, ...)

          // Read size
          uint256 _0x371522 = uint8(_0x724171 & 0x0f);
          uint256 _0x168144;
          (_0x168144, _0xabc74b) = _0x485c28._0xd558da(_0xabc74b, _0x371522);

          // Enter a branch of the signature merkle tree
          uint256 _0xff14a3 = _0xabc74b + _0x168144;

          (uint256 _0x912a68, bytes32 _0x3f119c) = _0x9fd1bf(_0xb4c39c, _0xce8606, _0x485c28[_0xabc74b:_0xff14a3]);
          _0xabc74b = _0xff14a3;

          _0x77424f += _0x912a68;
          _0x3ed99a = LibOptim._0x443a83(_0x3ed99a, _0x3f119c);
          continue;
        }

        // Nested (0x06)
        if (_0xe72026 == FLAG_NESTED) {
          // Unused free bits:
          // - XX00 : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)
          // - 00XX : Threshold (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Enter a branch of the signature merkle tree
          // but with an internal threshold and an external fixed weight
          uint256 _0x57106e = uint8(_0x724171 & 0x0c) >> 2;
          if (_0x57106e == 0) {
            (_0x57106e, _0xabc74b) = _0x485c28._0x856e39(_0xabc74b);
          }

          uint256 _0xe572c9 = uint8(_0x724171 & 0x03);
          if (_0xe572c9 == 0) {
            (_0xe572c9, _0xabc74b) = _0x485c28._0xf15eee(_0xabc74b);
          }

          uint256 _0x168144;
          (_0x168144, _0xabc74b) = _0x485c28._0xfdb3ea(_0xabc74b);
          uint256 _0xff14a3 = _0xabc74b + _0x168144;

          (uint256 _0xc11371, bytes32 _0x0fbaf8) = _0x9fd1bf(_0xb4c39c, _0xce8606, _0x485c28[_0xabc74b:_0xff14a3]);
          _0xabc74b = _0xff14a3;

          if (_0xc11371 >= _0xe572c9) {
            _0x77424f += _0x57106e;
          }

          bytes32 _0x3f119c = _0x16580c(_0x0fbaf8, _0xe572c9, _0x57106e);
          _0x3ed99a = _0x3ed99a != bytes32(0) ? LibOptim._0x443a83(_0x3ed99a, _0x3f119c) : _0x3f119c;
          continue;
        }

        // Subdigest (0x05)
        if (_0xe72026 == FLAG_SUBDIGEST) {
          // Free bits left unused

          // A hardcoded always accepted digest
          // it pushes the weight to the maximum
          bytes32 _0xfdf11c;
          (_0xfdf11c, _0xabc74b) = _0x485c28._0xbbe3d1(_0xabc74b);
          if (_0xfdf11c == _0xce8606) {
            _0x77424f = type(uint256)._0xbef178;
          }

          bytes32 _0x3f119c = _0x1ea614(_0xfdf11c);
          _0x3ed99a = _0x3ed99a != bytes32(0) ? LibOptim._0x443a83(_0x3ed99a, _0x3f119c) : _0x3f119c;
          continue;
        }

        // Signature ETH Sign (0x07)
        if (_0xe72026 == FLAG_SIGNATURE_ETH_SIGN) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, ..., 1111 = 15)
          // We read 64 bytes for an ERC-2098 compact signature (r, yParityAndS).
          // The top bit of yParityAndS is yParity, the remaining 255 bits are s.

          uint8 _0x635bdb = uint8(_0x724171 & 0x0f);
          if (_0x635bdb == 0) {
            (_0x635bdb, _0xabc74b) = _0x485c28._0x856e39(_0xabc74b);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xabc74b) = _0x485c28._0xd76b1d(_0xabc74b);

          address _0x1a6584 = _0x01809b(_0x8c6c8e(abi._0x5e2b7c("\x19Ethereum Signed Message:\n32", _0xce8606)), v, r, s);

          _0x77424f += _0x635bdb;
          bytes32 _0x3f119c = _0xbfe1a0(_0x1a6584, _0x635bdb);
          _0x3ed99a = _0x3ed99a != bytes32(0) ? LibOptim._0x443a83(_0x3ed99a, _0x3f119c) : _0x3f119c;
          continue;
        }

        // Signature Any address subdigest (0x08)
        // similar to subdigest, but allows for counter-factual payloads
        if (_0xe72026 == FLAG_SIGNATURE_ANY_ADDRESS_SUBDIGEST) {
          // Free bits left unused

          // A hardcoded always accepted digest
          // it pushes the weight to the maximum
          bytes32 _0xfdf11c;
          (_0xfdf11c, _0xabc74b) = _0x485c28._0xbbe3d1(_0xabc74b);
          bytes32 _0x8aa93c = _0xb4c39c._0xe26c97(address(0));
          if (_0xfdf11c == _0x8aa93c) {
            _0x77424f = type(uint256)._0xbef178;
          }

          bytes32 _0x3f119c = _0xd51f80(_0xfdf11c);
          _0x3ed99a = _0x3ed99a != bytes32(0) ? LibOptim._0x443a83(_0x3ed99a, _0x3f119c) : _0x3f119c;
          continue;
        }

        // Signature Sapient (0x09)
        if (_0xe72026 == FLAG_SIGNATURE_SAPIENT) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read signer and weight
          uint8 _0x635bdb = uint8(_0x724171 & 0x03);
          if (_0x635bdb == 0) {
            (_0x635bdb, _0xabc74b) = _0x485c28._0x856e39(_0xabc74b);
          }

          address _0x1a6584;
          (_0x1a6584, _0xabc74b) = _0x485c28._0x92a547(_0xabc74b);

          // Read signature size
          uint256 _0x168144;
          {
            uint256 _0x371522 = uint8(_0x724171 & 0x0c) >> 2;
            (_0x168144, _0xabc74b) = _0x485c28._0xd558da(_0xabc74b, _0x371522);
          }

          // Read dynamic size signature
          uint256 _0xff14a3 = _0xabc74b + _0x168144;

          // Call the ERC1271 contract to check if the signature is valid
          bytes32 _0xb2f0d4 = ISapient(_0x1a6584)._0xedf3f3(_0xb4c39c, _0x485c28[_0xabc74b:_0xff14a3]);
          _0xabc74b = _0xff14a3;

          // Add the weight and compute the merkle root
          _0x77424f += _0x635bdb;
          bytes32 _0x3f119c = _0x4a24cb(_0x1a6584, _0x635bdb, _0xb2f0d4);
          _0x3ed99a = _0x3ed99a != bytes32(0) ? LibOptim._0x443a83(_0x3ed99a, _0x3f119c) : _0x3f119c;
          continue;
        }

        // Signature Sapient Compact (0x0A)
        if (_0xe72026 == FLAG_SIGNATURE_SAPIENT_COMPACT) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read signer and weight
          uint8 _0x635bdb = uint8(_0x724171 & 0x03);
          if (_0x635bdb == 0) {
            (_0x635bdb, _0xabc74b) = _0x485c28._0x856e39(_0xabc74b);
          }

          address _0x1a6584;
          (_0x1a6584, _0xabc74b) = _0x485c28._0x92a547(_0xabc74b);

          // Read signature size
          uint256 _0x371522 = uint8(_0x724171 & 0x0c) >> 2;
          uint256 _0x168144;
          (_0x168144, _0xabc74b) = _0x485c28._0xd558da(_0xabc74b, _0x371522);

          // Read dynamic size signature
          uint256 _0xff14a3 = _0xabc74b + _0x168144;

          // Call the Sapient contract to check if the signature is valid
          bytes32 _0xb2f0d4 =
            ISapientCompact(_0x1a6584)._0xe7d04c(_0xce8606, _0x485c28[_0xabc74b:_0xff14a3]);
          _0xabc74b = _0xff14a3;
          // Add the weight and compute the merkle root
          _0x77424f += _0x635bdb;
          bytes32 _0x3f119c = _0x4a24cb(_0x1a6584, _0x635bdb, _0xb2f0d4);
          _0x3ed99a = _0x3ed99a != bytes32(0) ? LibOptim._0x443a83(_0x3ed99a, _0x3f119c) : _0x3f119c;
          continue;
        }

        revert InvalidSignatureFlag(_0xe72026);
      }
    }
  }

}
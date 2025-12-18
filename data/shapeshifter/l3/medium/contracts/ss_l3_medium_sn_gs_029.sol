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
  error LowWeightChainedSignature(bytes _0x2156cc, uint256 _0x9e5d8f, uint256 _0x8d5068);
  /// @notice Error thrown when the ERC1271 signature is invalid
  error InvalidERC1271Signature(bytes32 _0x749793, address _0x4f04ad, bytes _0x2156cc);
  /// @notice Error thrown when the checkpoint order is wrong
  error WrongChainedCheckpointOrder(uint256 _0xce1439, uint256 _0x6b7e1a);
  /// @notice Error thrown when the snapshot is unused
  error UnusedSnapshot(Snapshot _0x1f2a73);
  /// @notice Error thrown when the signature flag is invalid
  error InvalidSignatureFlag(uint256 _0xc41b55);

  function _0xc6b9d3(address _0xbdf13d, uint256 _0x8d5068) internal pure returns (bytes32) {
    return _0x066674(abi._0x00df95("Sequence signer:\n", _0xbdf13d, _0x8d5068));
  }

  function _0xd40d62(bytes32 _0x3d0faa, uint256 _0x9e5d8f, uint256 _0x8d5068) internal pure returns (bytes32) {
    return _0x066674(abi._0x00df95("Sequence nested config:\n", _0x3d0faa, _0x9e5d8f, _0x8d5068));
  }

  function _0xe464c7(address _0xbdf13d, uint256 _0x8d5068, bytes32 _0x9389a8) internal pure returns (bytes32) {
    return _0x066674(abi._0x00df95("Sequence sapient config:\n", _0xbdf13d, _0x8d5068, _0x9389a8));
  }

  function _0xc67c32(
    bytes32 _0xddd8f3
  ) internal pure returns (bytes32) {
    return _0x066674(abi._0x00df95("Sequence static digest:\n", _0xddd8f3));
  }

  function _0xf8672e(
    bytes32 _0x4792ad
  ) internal pure returns (bytes32) {
    return _0x066674(abi._0x00df95("Sequence any address subdigest:\n", _0x4792ad));
  }

  function _0xf64671(
    Payload.Decoded memory _0x43b8ff,
    bytes calldata _0x2156cc,
    bool _0x67fad7,
    address _0x2b9c1c
  ) internal view returns (uint256 _0x24ce88, uint256 _0x4be0b2, bytes32 _0x69e5ca, uint256 _0x55828a, bytes32 _0x92391c) {
    // First byte is the signature flag
    (uint256 _0x37ca11, uint256 _0xb7cfa6) = _0x2156cc._0xf4faaf();

    // The possible flags are:
    // - 0000 00XX (bits [1..0]): signature type (00 = normal, 01/11 = chained, 10 = no chain id)
    // - 000X XX00 (bits [4..2]): checkpoint size (00 = 0 bytes, 001 = 1 byte, 010 = 2 bytes...)
    // - 00X0 0000 (bit [5]): threshold size (0 = 1 byte, 1 = 2 bytes)
    // - 0X00 0000 (bit [6]): set if imageHash checkpointer is used
    // - X000 0000 (bit [7]): reserved by base-auth

    Snapshot memory _0x21925b;

    // Recover the imageHash checkpointer if any
    // but checkpointer passed as argument takes precedence
    // since it can be defined by the chained signatures
    if (_0x37ca11 & 0x40 == 0x40 && _0x2b9c1c == address(0)) {
      // Override the checkpointer
      // not ideal, but we don't have much room in the stack
      (_0x2b9c1c, _0xb7cfa6) = _0x2156cc._0x958091(_0xb7cfa6);

      if (!_0x67fad7) {
        // Next 3 bytes determine the checkpointer data size
        uint256 _0x20d8b4;
        (_0x20d8b4, _0xb7cfa6) = _0x2156cc._0x0e5190(_0xb7cfa6);

        // Read the checkpointer data
        bytes memory _0x97e5f7 = _0x2156cc[_0xb7cfa6:_0xb7cfa6 + _0x20d8b4];

        // Call the middleware
        _0x21925b = ICheckpointer(_0x2b9c1c)._0xe1bc68(address(this), _0x97e5f7);

        _0xb7cfa6 += _0x20d8b4;
      }
    }

    // If signature type is 01 or 11 we do a chained signature
    if (_0x37ca11 & 0x01 == 0x01) {
      return _0x2df066(_0x43b8ff, _0x2b9c1c, _0x21925b, _0x2156cc[_0xb7cfa6:]);
    }

    // If the signature type is 10 we do a no chain id signature
    _0x43b8ff._0xa74c7e = _0x37ca11 & 0x02 == 0x02;

    {
      // Recover the checkpoint using the size defined by the flag
      uint256 _0x0c0481 = (_0x37ca11 & 0x1c) >> 2;
      (_0x55828a, _0xb7cfa6) = _0x2156cc._0xc223e1(_0xb7cfa6, _0x0c0481);
    }

    // Recover the threshold, using the flag for the size
    {
      uint256 _0x0eefe8 = ((_0x37ca11 & 0x20) >> 5) + 1;
      (_0x24ce88, _0xb7cfa6) = _0x2156cc._0xc223e1(_0xb7cfa6, _0x0eefe8);
    }

    // Recover the tree
    _0x92391c = _0x43b8ff._0x13756b();
    (_0x4be0b2, _0x69e5ca) = _0x7128b7(_0x43b8ff, _0x92391c, _0x2156cc[_0xb7cfa6:]);

    _0x69e5ca = LibOptim._0x6b6d70(_0x69e5ca, bytes32(_0x24ce88));
    _0x69e5ca = LibOptim._0x6b6d70(_0x69e5ca, bytes32(_0x55828a));
    _0x69e5ca = LibOptim._0x6b6d70(_0x69e5ca, bytes32(uint256(uint160(_0x2b9c1c))));

    // If the snapshot is used, either the imageHash must match
    // or the checkpoint must be greater than the snapshot checkpoint
    if (_0x21925b._0x69e5ca != bytes32(0) && _0x21925b._0x69e5ca != _0x69e5ca && _0x55828a <= _0x21925b._0x55828a) {
      revert UnusedSnapshot(_0x21925b);
    }
  }

  function _0x2df066(
    Payload.Decoded memory _0x43b8ff,
    address _0x2b9c1c,
    Snapshot memory _0x1f2a73,
    bytes calldata _0x2156cc
  ) internal view returns (uint256 _0x24ce88, uint256 _0x4be0b2, bytes32 _0x69e5ca, uint256 _0x55828a, bytes32 _0x92391c) {
    Payload.Decoded memory _0x80afdc;
    _0x80afdc._0x119022 = Payload.KIND_CONFIG_UPDATE;

    uint256 _0xb7cfa6;
    uint256 _0x086899 = type(uint256)._0xbe9b0f;

    while (_0xb7cfa6 < _0x2156cc.length) {
      uint256 _0x2be409;

      {
        uint256 _0x56f070;
        (_0x56f070, _0xb7cfa6) = _0x2156cc._0x0e5190(_0xb7cfa6);
        _0x2be409 = _0x56f070 + _0xb7cfa6;
      }

      address _0xaaf3f1 = _0x2be409 == _0x2156cc.length ? _0x2b9c1c : address(0);

      if (_0x086899 == type(uint256)._0xbe9b0f) {
        (_0x24ce88, _0x4be0b2, _0x69e5ca, _0x55828a, _0x92391c) =
          _0xf64671(_0x43b8ff, _0x2156cc[_0xb7cfa6:_0x2be409], true, _0xaaf3f1);
      } else {
        (_0x24ce88, _0x4be0b2, _0x69e5ca, _0x55828a,) =
          _0xf64671(_0x80afdc, _0x2156cc[_0xb7cfa6:_0x2be409], true, _0xaaf3f1);
      }

      if (_0x4be0b2 < _0x24ce88) {
        revert LowWeightChainedSignature(_0x2156cc[_0xb7cfa6:_0x2be409], _0x24ce88, _0x4be0b2);
      }
      _0xb7cfa6 = _0x2be409;

      if (_0x1f2a73._0x69e5ca == _0x69e5ca) {
        _0x1f2a73._0x69e5ca = bytes32(0);
      }

      if (_0x55828a >= _0x086899) {
        revert WrongChainedCheckpointOrder(_0x55828a, _0x086899);
      }

      _0x80afdc._0x69e5ca = _0x69e5ca;
      _0x086899 = _0x55828a;
    }

    if (_0x1f2a73._0x69e5ca != bytes32(0) && _0x55828a <= _0x1f2a73._0x55828a) {
      revert UnusedSnapshot(_0x1f2a73);
    }
  }

  function _0x7128b7(
    Payload.Decoded memory _0x43b8ff,
    bytes32 _0x749793,
    bytes calldata _0x2156cc
  ) internal view returns (uint256 _0x4be0b2, bytes32 _0xfab7b2) {
    unchecked {
      uint256 _0xb7cfa6;

      // Iterate until the image is completed
      while (_0xb7cfa6 < _0x2156cc.length) {
        // The first byte is half flag (the top nibble)
        // and the second set of 4 bits can freely be used by the part

        // Read next item type
        uint256 _0x78f7ce;
        (_0x78f7ce, _0xb7cfa6) = _0x2156cc._0xd69d52(_0xb7cfa6);

        // The top 4 bits are the flag
        uint256 _0xc5e746 = (_0x78f7ce & 0xf0) >> 4;

        // Signature hash (0x00)
        if (_0xc5e746 == FLAG_SIGNATURE_HASH) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, ..., 1111 = 15)
          // We read 64 bytes for an ERC-2098 compact signature (r, yParityAndS).
          // The top bit of yParityAndS is yParity, the remaining 255 bits are s.

          uint8 _0x37b2be = uint8(_0x78f7ce & 0x0f);
          if (_0x37b2be == 0) {
            (_0x37b2be, _0xb7cfa6) = _0x2156cc._0xd69d52(_0xb7cfa6);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xb7cfa6) = _0x2156cc._0x7b885e(_0xb7cfa6);

          address _0x144589 = _0x4a5e86(_0x749793, v, r, s);

          _0x4be0b2 += _0x37b2be;
          bytes32 _0x9c3de8 = _0xc6b9d3(_0x144589, _0x37b2be);
          _0xfab7b2 = _0xfab7b2 != bytes32(0) ? LibOptim._0x6b6d70(_0xfab7b2, _0x9c3de8) : _0x9c3de8;
          continue;
        }

        // Address (0x01) (without signature)
        if (_0xc5e746 == FLAG_ADDRESS) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, 0010 = 2, ...)

          // Read weight
          uint8 _0x37b2be = uint8(_0x78f7ce & 0x0f);
          if (_0x37b2be == 0) {
            (_0x37b2be, _0xb7cfa6) = _0x2156cc._0xd69d52(_0xb7cfa6);
          }

          // Read address
          address _0x144589;
          (_0x144589, _0xb7cfa6) = _0x2156cc._0x958091(_0xb7cfa6);

          // Compute the merkle root WITHOUT adding the weight
          bytes32 _0x9c3de8 = _0xc6b9d3(_0x144589, _0x37b2be);
          _0xfab7b2 = _0xfab7b2 != bytes32(0) ? LibOptim._0x6b6d70(_0xfab7b2, _0x9c3de8) : _0x9c3de8;
          continue;
        }

        // Signature ERC1271 (0x02)
        if (_0xc5e746 == FLAG_SIGNATURE_ERC1271) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read weight
          uint8 _0x37b2be = uint8(_0x78f7ce & 0x03);
          if (_0x37b2be == 0) {
            (_0x37b2be, _0xb7cfa6) = _0x2156cc._0xd69d52(_0xb7cfa6);
          }

          // Read signer
          address _0x144589;
          (_0x144589, _0xb7cfa6) = _0x2156cc._0x958091(_0xb7cfa6);

          // Read signature size
          uint256 _0x60f6e0 = uint8(_0x78f7ce & 0x0c) >> 2;
          uint256 _0x024b79;
          (_0x024b79, _0xb7cfa6) = _0x2156cc._0xc223e1(_0xb7cfa6, _0x60f6e0);

          // Read dynamic size signature
          uint256 _0x2be409 = _0xb7cfa6 + _0x024b79;

          // Call the ERC1271 contract to check if the signature is valid
          if (IERC1271(_0x144589)._0x0bcb37(_0x749793, _0x2156cc[_0xb7cfa6:_0x2be409]) != IERC1271_MAGIC_VALUE_HASH) {
            revert InvalidERC1271Signature(_0x749793, _0x144589, _0x2156cc[_0xb7cfa6:_0x2be409]);
          }
          _0xb7cfa6 = _0x2be409;
          // Add the weight and compute the merkle root
          _0x4be0b2 += _0x37b2be;
          bytes32 _0x9c3de8 = _0xc6b9d3(_0x144589, _0x37b2be);
          _0xfab7b2 = _0xfab7b2 != bytes32(0) ? LibOptim._0x6b6d70(_0xfab7b2, _0x9c3de8) : _0x9c3de8;
          continue;
        }

        // Node (0x03)
        if (_0xc5e746 == FLAG_NODE) {
          // Free bits left unused

          // Read node hash
          bytes32 _0x9c3de8;
          (_0x9c3de8, _0xb7cfa6) = _0x2156cc._0xd40681(_0xb7cfa6);
          _0xfab7b2 = _0xfab7b2 != bytes32(0) ? LibOptim._0x6b6d70(_0xfab7b2, _0x9c3de8) : _0x9c3de8;
          continue;
        }

        // Branch (0x04)
        if (_0xc5e746 == FLAG_BRANCH) {
          // Free bits layout:
          // - XXXX : Size size (0000 = 0 byte, 0001 = 1 byte, 0010 = 2 bytes, ...)

          // Read size
          uint256 _0x60f6e0 = uint8(_0x78f7ce & 0x0f);
          uint256 _0x024b79;
          (_0x024b79, _0xb7cfa6) = _0x2156cc._0xc223e1(_0xb7cfa6, _0x60f6e0);

          // Enter a branch of the signature merkle tree
          uint256 _0x2be409 = _0xb7cfa6 + _0x024b79;

          (uint256 _0xe2c34b, bytes32 _0x9c3de8) = _0x7128b7(_0x43b8ff, _0x749793, _0x2156cc[_0xb7cfa6:_0x2be409]);
          _0xb7cfa6 = _0x2be409;

          _0x4be0b2 += _0xe2c34b;
          _0xfab7b2 = LibOptim._0x6b6d70(_0xfab7b2, _0x9c3de8);
          continue;
        }

        // Nested (0x06)
        if (_0xc5e746 == FLAG_NESTED) {
          // Unused free bits:
          // - XX00 : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)
          // - 00XX : Threshold (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Enter a branch of the signature merkle tree
          // but with an internal threshold and an external fixed weight
          uint256 _0x564c28 = uint8(_0x78f7ce & 0x0c) >> 2;
          if (_0x564c28 == 0) {
            (_0x564c28, _0xb7cfa6) = _0x2156cc._0xd69d52(_0xb7cfa6);
          }

          uint256 _0x715797 = uint8(_0x78f7ce & 0x03);
          if (_0x715797 == 0) {
            (_0x715797, _0xb7cfa6) = _0x2156cc._0xcf88d7(_0xb7cfa6);
          }

          uint256 _0x024b79;
          (_0x024b79, _0xb7cfa6) = _0x2156cc._0x0e5190(_0xb7cfa6);
          uint256 _0x2be409 = _0xb7cfa6 + _0x024b79;

          (uint256 _0xc72cf2, bytes32 _0x8b876d) = _0x7128b7(_0x43b8ff, _0x749793, _0x2156cc[_0xb7cfa6:_0x2be409]);
          _0xb7cfa6 = _0x2be409;

          if (_0xc72cf2 >= _0x715797) {
            _0x4be0b2 += _0x564c28;
          }

          bytes32 _0x9c3de8 = _0xd40d62(_0x8b876d, _0x715797, _0x564c28);
          _0xfab7b2 = _0xfab7b2 != bytes32(0) ? LibOptim._0x6b6d70(_0xfab7b2, _0x9c3de8) : _0x9c3de8;
          continue;
        }

        // Subdigest (0x05)
        if (_0xc5e746 == FLAG_SUBDIGEST) {
          // Free bits left unused

          // A hardcoded always accepted digest
          // it pushes the weight to the maximum
          bytes32 _0xa7c779;
          (_0xa7c779, _0xb7cfa6) = _0x2156cc._0xd40681(_0xb7cfa6);
          if (_0xa7c779 == _0x749793) {
            _0x4be0b2 = type(uint256)._0xbe9b0f;
          }

          bytes32 _0x9c3de8 = _0xc67c32(_0xa7c779);
          _0xfab7b2 = _0xfab7b2 != bytes32(0) ? LibOptim._0x6b6d70(_0xfab7b2, _0x9c3de8) : _0x9c3de8;
          continue;
        }

        // Signature ETH Sign (0x07)
        if (_0xc5e746 == FLAG_SIGNATURE_ETH_SIGN) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, ..., 1111 = 15)
          // We read 64 bytes for an ERC-2098 compact signature (r, yParityAndS).
          // The top bit of yParityAndS is yParity, the remaining 255 bits are s.

          uint8 _0x37b2be = uint8(_0x78f7ce & 0x0f);
          if (_0x37b2be == 0) {
            (_0x37b2be, _0xb7cfa6) = _0x2156cc._0xd69d52(_0xb7cfa6);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xb7cfa6) = _0x2156cc._0x7b885e(_0xb7cfa6);

          address _0x144589 = _0x4a5e86(_0x066674(abi._0x00df95("\x19Ethereum Signed Message:\n32", _0x749793)), v, r, s);

          _0x4be0b2 += _0x37b2be;
          bytes32 _0x9c3de8 = _0xc6b9d3(_0x144589, _0x37b2be);
          _0xfab7b2 = _0xfab7b2 != bytes32(0) ? LibOptim._0x6b6d70(_0xfab7b2, _0x9c3de8) : _0x9c3de8;
          continue;
        }

        // Signature Any address subdigest (0x08)
        // similar to subdigest, but allows for counter-factual payloads
        if (_0xc5e746 == FLAG_SIGNATURE_ANY_ADDRESS_SUBDIGEST) {
          // Free bits left unused

          // A hardcoded always accepted digest
          // it pushes the weight to the maximum
          bytes32 _0xa7c779;
          (_0xa7c779, _0xb7cfa6) = _0x2156cc._0xd40681(_0xb7cfa6);
          bytes32 _0x713c30 = _0x43b8ff._0x1ff4ee(address(0));
          if (_0xa7c779 == _0x713c30) {
            _0x4be0b2 = type(uint256)._0xbe9b0f;
          }

          bytes32 _0x9c3de8 = _0xf8672e(_0xa7c779);
          _0xfab7b2 = _0xfab7b2 != bytes32(0) ? LibOptim._0x6b6d70(_0xfab7b2, _0x9c3de8) : _0x9c3de8;
          continue;
        }

        // Signature Sapient (0x09)
        if (_0xc5e746 == FLAG_SIGNATURE_SAPIENT) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read signer and weight
          uint8 _0x37b2be = uint8(_0x78f7ce & 0x03);
          if (_0x37b2be == 0) {
            (_0x37b2be, _0xb7cfa6) = _0x2156cc._0xd69d52(_0xb7cfa6);
          }

          address _0x144589;
          (_0x144589, _0xb7cfa6) = _0x2156cc._0x958091(_0xb7cfa6);

          // Read signature size
          uint256 _0x024b79;
          {
            uint256 _0x60f6e0 = uint8(_0x78f7ce & 0x0c) >> 2;
            (_0x024b79, _0xb7cfa6) = _0x2156cc._0xc223e1(_0xb7cfa6, _0x60f6e0);
          }

          // Read dynamic size signature
          uint256 _0x2be409 = _0xb7cfa6 + _0x024b79;

          // Call the ERC1271 contract to check if the signature is valid
          bytes32 _0x2d2c70 = ISapient(_0x144589)._0x38a032(_0x43b8ff, _0x2156cc[_0xb7cfa6:_0x2be409]);
          _0xb7cfa6 = _0x2be409;

          // Add the weight and compute the merkle root
          _0x4be0b2 += _0x37b2be;
          bytes32 _0x9c3de8 = _0xe464c7(_0x144589, _0x37b2be, _0x2d2c70);
          _0xfab7b2 = _0xfab7b2 != bytes32(0) ? LibOptim._0x6b6d70(_0xfab7b2, _0x9c3de8) : _0x9c3de8;
          continue;
        }

        // Signature Sapient Compact (0x0A)
        if (_0xc5e746 == FLAG_SIGNATURE_SAPIENT_COMPACT) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read signer and weight
          uint8 _0x37b2be = uint8(_0x78f7ce & 0x03);
          if (_0x37b2be == 0) {
            (_0x37b2be, _0xb7cfa6) = _0x2156cc._0xd69d52(_0xb7cfa6);
          }

          address _0x144589;
          (_0x144589, _0xb7cfa6) = _0x2156cc._0x958091(_0xb7cfa6);

          // Read signature size
          uint256 _0x60f6e0 = uint8(_0x78f7ce & 0x0c) >> 2;
          uint256 _0x024b79;
          (_0x024b79, _0xb7cfa6) = _0x2156cc._0xc223e1(_0xb7cfa6, _0x60f6e0);

          // Read dynamic size signature
          uint256 _0x2be409 = _0xb7cfa6 + _0x024b79;

          // Call the Sapient contract to check if the signature is valid
          bytes32 _0x2d2c70 =
            ISapientCompact(_0x144589)._0x433a26(_0x749793, _0x2156cc[_0xb7cfa6:_0x2be409]);
          _0xb7cfa6 = _0x2be409;
          // Add the weight and compute the merkle root
          _0x4be0b2 += _0x37b2be;
          bytes32 _0x9c3de8 = _0xe464c7(_0x144589, _0x37b2be, _0x2d2c70);
          _0xfab7b2 = _0xfab7b2 != bytes32(0) ? LibOptim._0x6b6d70(_0xfab7b2, _0x9c3de8) : _0x9c3de8;
          continue;
        }

        revert InvalidSignatureFlag(_0xc5e746);
      }
    }
  }

}
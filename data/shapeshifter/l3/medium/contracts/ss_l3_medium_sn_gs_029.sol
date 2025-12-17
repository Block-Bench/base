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
  error LowWeightChainedSignature(bytes _0x5e4311, uint256 _0xcd08cd, uint256 _0x5d82c6);
  /// @notice Error thrown when the ERC1271 signature is invalid
  error InvalidERC1271Signature(bytes32 _0x42164d, address _0xe4af84, bytes _0x5e4311);
  /// @notice Error thrown when the checkpoint order is wrong
  error WrongChainedCheckpointOrder(uint256 _0x0634e6, uint256 _0xd5a87f);
  /// @notice Error thrown when the snapshot is unused
  error UnusedSnapshot(Snapshot _0xaffb01);
  /// @notice Error thrown when the signature flag is invalid
  error InvalidSignatureFlag(uint256 _0xe3c9df);

  function _0xe502cd(address _0x753b07, uint256 _0x5d82c6) internal pure returns (bytes32) {
    return _0xa87ec2(abi._0xa6265d("Sequence signer:\n", _0x753b07, _0x5d82c6));
  }

  function _0x8d96c6(bytes32 _0x4c3034, uint256 _0xcd08cd, uint256 _0x5d82c6) internal pure returns (bytes32) {
    return _0xa87ec2(abi._0xa6265d("Sequence nested config:\n", _0x4c3034, _0xcd08cd, _0x5d82c6));
  }

  function _0x09a750(address _0x753b07, uint256 _0x5d82c6, bytes32 _0x6a40d6) internal pure returns (bytes32) {
    return _0xa87ec2(abi._0xa6265d("Sequence sapient config:\n", _0x753b07, _0x5d82c6, _0x6a40d6));
  }

  function _0xe1e9e5(
    bytes32 _0xa4c338
  ) internal pure returns (bytes32) {
    return _0xa87ec2(abi._0xa6265d("Sequence static digest:\n", _0xa4c338));
  }

  function _0x5f9234(
    bytes32 _0xe1ade6
  ) internal pure returns (bytes32) {
    return _0xa87ec2(abi._0xa6265d("Sequence any address subdigest:\n", _0xe1ade6));
  }

  function _0xeb607d(
    Payload.Decoded memory _0xa7c4e2,
    bytes calldata _0x5e4311,
    bool _0x44fb97,
    address _0xd49d0c
  ) internal view returns (uint256 _0x304d06, uint256 _0x771862, bytes32 _0x2a3c49, uint256 _0x5fa4df, bytes32 _0xa8b3fb) {
    // First byte is the signature flag
    (uint256 _0x5e8106, uint256 _0xb16d4d) = _0x5e4311._0x884e3d();

    // The possible flags are:
    // - 0000 00XX (bits [1..0]): signature type (00 = normal, 01/11 = chained, 10 = no chain id)
    // - 000X XX00 (bits [4..2]): checkpoint size (00 = 0 bytes, 001 = 1 byte, 010 = 2 bytes...)
    // - 00X0 0000 (bit [5]): threshold size (0 = 1 byte, 1 = 2 bytes)
    // - 0X00 0000 (bit [6]): set if imageHash checkpointer is used
    // - X000 0000 (bit [7]): reserved by base-auth

    Snapshot memory _0x93bf79;

    // Recover the imageHash checkpointer if any
    // but checkpointer passed as argument takes precedence
    // since it can be defined by the chained signatures
    if (_0x5e8106 & 0x40 == 0x40 && _0xd49d0c == address(0)) {
      // Override the checkpointer
      // not ideal, but we don't have much room in the stack
      (_0xd49d0c, _0xb16d4d) = _0x5e4311._0x2edd46(_0xb16d4d);

      if (!_0x44fb97) {
        // Next 3 bytes determine the checkpointer data size
        uint256 _0xe91c40;
        (_0xe91c40, _0xb16d4d) = _0x5e4311._0xc58f74(_0xb16d4d);

        // Read the checkpointer data
        bytes memory _0x50e138 = _0x5e4311[_0xb16d4d:_0xb16d4d + _0xe91c40];

        // Call the middleware
        _0x93bf79 = ICheckpointer(_0xd49d0c)._0xb3433f(address(this), _0x50e138);

        _0xb16d4d += _0xe91c40;
      }
    }

    // If signature type is 01 or 11 we do a chained signature
    if (_0x5e8106 & 0x01 == 0x01) {
      return _0x67d80d(_0xa7c4e2, _0xd49d0c, _0x93bf79, _0x5e4311[_0xb16d4d:]);
    }

    // If the signature type is 10 we do a no chain id signature
    _0xa7c4e2._0xee6193 = _0x5e8106 & 0x02 == 0x02;

    {
      // Recover the checkpoint using the size defined by the flag
      uint256 _0xdee3b4 = (_0x5e8106 & 0x1c) >> 2;
      (_0x5fa4df, _0xb16d4d) = _0x5e4311._0x3dcb48(_0xb16d4d, _0xdee3b4);
    }

    // Recover the threshold, using the flag for the size
    {
      uint256 _0xc1db23 = ((_0x5e8106 & 0x20) >> 5) + 1;
      (_0x304d06, _0xb16d4d) = _0x5e4311._0x3dcb48(_0xb16d4d, _0xc1db23);
    }

    // Recover the tree
    _0xa8b3fb = _0xa7c4e2._0xd94ebd();
    (_0x771862, _0x2a3c49) = _0x3808cf(_0xa7c4e2, _0xa8b3fb, _0x5e4311[_0xb16d4d:]);

    _0x2a3c49 = LibOptim._0xf2f208(_0x2a3c49, bytes32(_0x304d06));
    _0x2a3c49 = LibOptim._0xf2f208(_0x2a3c49, bytes32(_0x5fa4df));
    _0x2a3c49 = LibOptim._0xf2f208(_0x2a3c49, bytes32(uint256(uint160(_0xd49d0c))));

    // If the snapshot is used, either the imageHash must match
    // or the checkpoint must be greater than the snapshot checkpoint
    if (_0x93bf79._0x2a3c49 != bytes32(0) && _0x93bf79._0x2a3c49 != _0x2a3c49 && _0x5fa4df <= _0x93bf79._0x5fa4df) {
      revert UnusedSnapshot(_0x93bf79);
    }
  }

  function _0x67d80d(
    Payload.Decoded memory _0xa7c4e2,
    address _0xd49d0c,
    Snapshot memory _0xaffb01,
    bytes calldata _0x5e4311
  ) internal view returns (uint256 _0x304d06, uint256 _0x771862, bytes32 _0x2a3c49, uint256 _0x5fa4df, bytes32 _0xa8b3fb) {
    Payload.Decoded memory _0x62ac50;
    _0x62ac50._0x1f529e = Payload.KIND_CONFIG_UPDATE;

    uint256 _0xb16d4d;
    uint256 _0x2194fc = type(uint256)._0xf40cde;

    while (_0xb16d4d < _0x5e4311.length) {
      uint256 _0xfd4493;

      {
        uint256 _0x74ed7d;
        (_0x74ed7d, _0xb16d4d) = _0x5e4311._0xc58f74(_0xb16d4d);
        _0xfd4493 = _0x74ed7d + _0xb16d4d;
      }

      address _0x40e96c = _0xfd4493 == _0x5e4311.length ? _0xd49d0c : address(0);

      if (_0x2194fc == type(uint256)._0xf40cde) {
        (_0x304d06, _0x771862, _0x2a3c49, _0x5fa4df, _0xa8b3fb) =
          _0xeb607d(_0xa7c4e2, _0x5e4311[_0xb16d4d:_0xfd4493], true, _0x40e96c);
      } else {
        (_0x304d06, _0x771862, _0x2a3c49, _0x5fa4df,) =
          _0xeb607d(_0x62ac50, _0x5e4311[_0xb16d4d:_0xfd4493], true, _0x40e96c);
      }

      if (_0x771862 < _0x304d06) {
        revert LowWeightChainedSignature(_0x5e4311[_0xb16d4d:_0xfd4493], _0x304d06, _0x771862);
      }
      _0xb16d4d = _0xfd4493;

      if (_0xaffb01._0x2a3c49 == _0x2a3c49) {
        _0xaffb01._0x2a3c49 = bytes32(0);
      }

      if (_0x5fa4df >= _0x2194fc) {
        revert WrongChainedCheckpointOrder(_0x5fa4df, _0x2194fc);
      }

      _0x62ac50._0x2a3c49 = _0x2a3c49;
      _0x2194fc = _0x5fa4df;
    }

    if (_0xaffb01._0x2a3c49 != bytes32(0) && _0x5fa4df <= _0xaffb01._0x5fa4df) {
      revert UnusedSnapshot(_0xaffb01);
    }
  }

  function _0x3808cf(
    Payload.Decoded memory _0xa7c4e2,
    bytes32 _0x42164d,
    bytes calldata _0x5e4311
  ) internal view returns (uint256 _0x771862, bytes32 _0x8636bb) {
    unchecked {
      uint256 _0xb16d4d;

      // Iterate until the image is completed
      while (_0xb16d4d < _0x5e4311.length) {
        // The first byte is half flag (the top nibble)
        // and the second set of 4 bits can freely be used by the part

        // Read next item type
        uint256 _0x486b66;
        (_0x486b66, _0xb16d4d) = _0x5e4311._0xe02997(_0xb16d4d);

        // The top 4 bits are the flag
        uint256 _0x34e945 = (_0x486b66 & 0xf0) >> 4;

        // Signature hash (0x00)
        if (_0x34e945 == FLAG_SIGNATURE_HASH) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, ..., 1111 = 15)
          // We read 64 bytes for an ERC-2098 compact signature (r, yParityAndS).
          // The top bit of yParityAndS is yParity, the remaining 255 bits are s.

          uint8 _0x21b150 = uint8(_0x486b66 & 0x0f);
          if (_0x21b150 == 0) {
            (_0x21b150, _0xb16d4d) = _0x5e4311._0xe02997(_0xb16d4d);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xb16d4d) = _0x5e4311._0xa7181e(_0xb16d4d);

          address _0x208f29 = _0x4e263e(_0x42164d, v, r, s);

          _0x771862 += _0x21b150;
          bytes32 _0xfd524a = _0xe502cd(_0x208f29, _0x21b150);
          _0x8636bb = _0x8636bb != bytes32(0) ? LibOptim._0xf2f208(_0x8636bb, _0xfd524a) : _0xfd524a;
          continue;
        }

        // Address (0x01) (without signature)
        if (_0x34e945 == FLAG_ADDRESS) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, 0010 = 2, ...)

          // Read weight
          uint8 _0x21b150 = uint8(_0x486b66 & 0x0f);
          if (_0x21b150 == 0) {
            (_0x21b150, _0xb16d4d) = _0x5e4311._0xe02997(_0xb16d4d);
          }

          // Read address
          address _0x208f29;
          (_0x208f29, _0xb16d4d) = _0x5e4311._0x2edd46(_0xb16d4d);

          // Compute the merkle root WITHOUT adding the weight
          bytes32 _0xfd524a = _0xe502cd(_0x208f29, _0x21b150);
          _0x8636bb = _0x8636bb != bytes32(0) ? LibOptim._0xf2f208(_0x8636bb, _0xfd524a) : _0xfd524a;
          continue;
        }

        // Signature ERC1271 (0x02)
        if (_0x34e945 == FLAG_SIGNATURE_ERC1271) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read weight
          uint8 _0x21b150 = uint8(_0x486b66 & 0x03);
          if (_0x21b150 == 0) {
            (_0x21b150, _0xb16d4d) = _0x5e4311._0xe02997(_0xb16d4d);
          }

          // Read signer
          address _0x208f29;
          (_0x208f29, _0xb16d4d) = _0x5e4311._0x2edd46(_0xb16d4d);

          // Read signature size
          uint256 _0x211f01 = uint8(_0x486b66 & 0x0c) >> 2;
          uint256 _0xd9bf28;
          (_0xd9bf28, _0xb16d4d) = _0x5e4311._0x3dcb48(_0xb16d4d, _0x211f01);

          // Read dynamic size signature
          uint256 _0xfd4493 = _0xb16d4d + _0xd9bf28;

          // Call the ERC1271 contract to check if the signature is valid
          if (IERC1271(_0x208f29)._0x36a754(_0x42164d, _0x5e4311[_0xb16d4d:_0xfd4493]) != IERC1271_MAGIC_VALUE_HASH) {
            revert InvalidERC1271Signature(_0x42164d, _0x208f29, _0x5e4311[_0xb16d4d:_0xfd4493]);
          }
          _0xb16d4d = _0xfd4493;
          // Add the weight and compute the merkle root
          _0x771862 += _0x21b150;
          bytes32 _0xfd524a = _0xe502cd(_0x208f29, _0x21b150);
          _0x8636bb = _0x8636bb != bytes32(0) ? LibOptim._0xf2f208(_0x8636bb, _0xfd524a) : _0xfd524a;
          continue;
        }

        // Node (0x03)
        if (_0x34e945 == FLAG_NODE) {
          // Free bits left unused

          // Read node hash
          bytes32 _0xfd524a;
          (_0xfd524a, _0xb16d4d) = _0x5e4311._0x80c542(_0xb16d4d);
          _0x8636bb = _0x8636bb != bytes32(0) ? LibOptim._0xf2f208(_0x8636bb, _0xfd524a) : _0xfd524a;
          continue;
        }

        // Branch (0x04)
        if (_0x34e945 == FLAG_BRANCH) {
          // Free bits layout:
          // - XXXX : Size size (0000 = 0 byte, 0001 = 1 byte, 0010 = 2 bytes, ...)

          // Read size
          uint256 _0x211f01 = uint8(_0x486b66 & 0x0f);
          uint256 _0xd9bf28;
          (_0xd9bf28, _0xb16d4d) = _0x5e4311._0x3dcb48(_0xb16d4d, _0x211f01);

          // Enter a branch of the signature merkle tree
          uint256 _0xfd4493 = _0xb16d4d + _0xd9bf28;

          (uint256 _0xaa5ca8, bytes32 _0xfd524a) = _0x3808cf(_0xa7c4e2, _0x42164d, _0x5e4311[_0xb16d4d:_0xfd4493]);
          _0xb16d4d = _0xfd4493;

          _0x771862 += _0xaa5ca8;
          _0x8636bb = LibOptim._0xf2f208(_0x8636bb, _0xfd524a);
          continue;
        }

        // Nested (0x06)
        if (_0x34e945 == FLAG_NESTED) {
          // Unused free bits:
          // - XX00 : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)
          // - 00XX : Threshold (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Enter a branch of the signature merkle tree
          // but with an internal threshold and an external fixed weight
          uint256 _0xc15bad = uint8(_0x486b66 & 0x0c) >> 2;
          if (_0xc15bad == 0) {
            (_0xc15bad, _0xb16d4d) = _0x5e4311._0xe02997(_0xb16d4d);
          }

          uint256 _0x45bad0 = uint8(_0x486b66 & 0x03);
          if (_0x45bad0 == 0) {
            (_0x45bad0, _0xb16d4d) = _0x5e4311._0xdcfe87(_0xb16d4d);
          }

          uint256 _0xd9bf28;
          (_0xd9bf28, _0xb16d4d) = _0x5e4311._0xc58f74(_0xb16d4d);
          uint256 _0xfd4493 = _0xb16d4d + _0xd9bf28;

          (uint256 _0xbb487d, bytes32 _0xa258b0) = _0x3808cf(_0xa7c4e2, _0x42164d, _0x5e4311[_0xb16d4d:_0xfd4493]);
          _0xb16d4d = _0xfd4493;

          if (_0xbb487d >= _0x45bad0) {
            _0x771862 += _0xc15bad;
          }

          bytes32 _0xfd524a = _0x8d96c6(_0xa258b0, _0x45bad0, _0xc15bad);
          _0x8636bb = _0x8636bb != bytes32(0) ? LibOptim._0xf2f208(_0x8636bb, _0xfd524a) : _0xfd524a;
          continue;
        }

        // Subdigest (0x05)
        if (_0x34e945 == FLAG_SUBDIGEST) {
          // Free bits left unused

          // A hardcoded always accepted digest
          // it pushes the weight to the maximum
          bytes32 _0xdcc809;
          (_0xdcc809, _0xb16d4d) = _0x5e4311._0x80c542(_0xb16d4d);
          if (_0xdcc809 == _0x42164d) {
            _0x771862 = type(uint256)._0xf40cde;
          }

          bytes32 _0xfd524a = _0xe1e9e5(_0xdcc809);
          _0x8636bb = _0x8636bb != bytes32(0) ? LibOptim._0xf2f208(_0x8636bb, _0xfd524a) : _0xfd524a;
          continue;
        }

        // Signature ETH Sign (0x07)
        if (_0x34e945 == FLAG_SIGNATURE_ETH_SIGN) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, ..., 1111 = 15)
          // We read 64 bytes for an ERC-2098 compact signature (r, yParityAndS).
          // The top bit of yParityAndS is yParity, the remaining 255 bits are s.

          uint8 _0x21b150 = uint8(_0x486b66 & 0x0f);
          if (_0x21b150 == 0) {
            (_0x21b150, _0xb16d4d) = _0x5e4311._0xe02997(_0xb16d4d);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xb16d4d) = _0x5e4311._0xa7181e(_0xb16d4d);

          address _0x208f29 = _0x4e263e(_0xa87ec2(abi._0xa6265d("\x19Ethereum Signed Message:\n32", _0x42164d)), v, r, s);

          _0x771862 += _0x21b150;
          bytes32 _0xfd524a = _0xe502cd(_0x208f29, _0x21b150);
          _0x8636bb = _0x8636bb != bytes32(0) ? LibOptim._0xf2f208(_0x8636bb, _0xfd524a) : _0xfd524a;
          continue;
        }

        // Signature Any address subdigest (0x08)
        // similar to subdigest, but allows for counter-factual payloads
        if (_0x34e945 == FLAG_SIGNATURE_ANY_ADDRESS_SUBDIGEST) {
          // Free bits left unused

          // A hardcoded always accepted digest
          // it pushes the weight to the maximum
          bytes32 _0xdcc809;
          (_0xdcc809, _0xb16d4d) = _0x5e4311._0x80c542(_0xb16d4d);
          bytes32 _0xe3146c = _0xa7c4e2._0xedadcc(address(0));
          if (_0xdcc809 == _0xe3146c) {
            _0x771862 = type(uint256)._0xf40cde;
          }

          bytes32 _0xfd524a = _0x5f9234(_0xdcc809);
          _0x8636bb = _0x8636bb != bytes32(0) ? LibOptim._0xf2f208(_0x8636bb, _0xfd524a) : _0xfd524a;
          continue;
        }

        // Signature Sapient (0x09)
        if (_0x34e945 == FLAG_SIGNATURE_SAPIENT) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read signer and weight
          uint8 _0x21b150 = uint8(_0x486b66 & 0x03);
          if (_0x21b150 == 0) {
            (_0x21b150, _0xb16d4d) = _0x5e4311._0xe02997(_0xb16d4d);
          }

          address _0x208f29;
          (_0x208f29, _0xb16d4d) = _0x5e4311._0x2edd46(_0xb16d4d);

          // Read signature size
          uint256 _0xd9bf28;
          {
            uint256 _0x211f01 = uint8(_0x486b66 & 0x0c) >> 2;
            (_0xd9bf28, _0xb16d4d) = _0x5e4311._0x3dcb48(_0xb16d4d, _0x211f01);
          }

          // Read dynamic size signature
          uint256 _0xfd4493 = _0xb16d4d + _0xd9bf28;

          // Call the ERC1271 contract to check if the signature is valid
          bytes32 _0xdeac94 = ISapient(_0x208f29)._0x4ee4da(_0xa7c4e2, _0x5e4311[_0xb16d4d:_0xfd4493]);
          _0xb16d4d = _0xfd4493;

          // Add the weight and compute the merkle root
          _0x771862 += _0x21b150;
          bytes32 _0xfd524a = _0x09a750(_0x208f29, _0x21b150, _0xdeac94);
          _0x8636bb = _0x8636bb != bytes32(0) ? LibOptim._0xf2f208(_0x8636bb, _0xfd524a) : _0xfd524a;
          continue;
        }

        // Signature Sapient Compact (0x0A)
        if (_0x34e945 == FLAG_SIGNATURE_SAPIENT_COMPACT) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read signer and weight
          uint8 _0x21b150 = uint8(_0x486b66 & 0x03);
          if (_0x21b150 == 0) {
            (_0x21b150, _0xb16d4d) = _0x5e4311._0xe02997(_0xb16d4d);
          }

          address _0x208f29;
          (_0x208f29, _0xb16d4d) = _0x5e4311._0x2edd46(_0xb16d4d);

          // Read signature size
          uint256 _0x211f01 = uint8(_0x486b66 & 0x0c) >> 2;
          uint256 _0xd9bf28;
          (_0xd9bf28, _0xb16d4d) = _0x5e4311._0x3dcb48(_0xb16d4d, _0x211f01);

          // Read dynamic size signature
          uint256 _0xfd4493 = _0xb16d4d + _0xd9bf28;

          // Call the Sapient contract to check if the signature is valid
          bytes32 _0xdeac94 =
            ISapientCompact(_0x208f29)._0xf6edbd(_0x42164d, _0x5e4311[_0xb16d4d:_0xfd4493]);
          _0xb16d4d = _0xfd4493;
          // Add the weight and compute the merkle root
          _0x771862 += _0x21b150;
          bytes32 _0xfd524a = _0x09a750(_0x208f29, _0x21b150, _0xdeac94);
          _0x8636bb = _0x8636bb != bytes32(0) ? LibOptim._0xf2f208(_0x8636bb, _0xfd524a) : _0xfd524a;
          continue;
        }

        revert InvalidSignatureFlag(_0x34e945);
      }
    }
  }

}
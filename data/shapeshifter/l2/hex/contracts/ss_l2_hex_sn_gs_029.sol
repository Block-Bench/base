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
  error LowWeightChainedSignature(bytes _0x84ef49, uint256 _0xcfc988, uint256 _0x1a6d5d);
  /// @notice Error thrown when the ERC1271 signature is invalid
  error InvalidERC1271Signature(bytes32 _0x142400, address _0xc6baa0, bytes _0x84ef49);
  /// @notice Error thrown when the checkpoint order is wrong
  error WrongChainedCheckpointOrder(uint256 _0xe381f6, uint256 _0xf069ee);
  /// @notice Error thrown when the snapshot is unused
  error UnusedSnapshot(Snapshot _0x375c95);
  /// @notice Error thrown when the signature flag is invalid
  error InvalidSignatureFlag(uint256 _0x076740);

  function _0x65b714(address _0xccfa91, uint256 _0x1a6d5d) internal pure returns (bytes32) {
    return _0x8c2ba0(abi._0x3ae912("Sequence signer:\n", _0xccfa91, _0x1a6d5d));
  }

  function _0xa3ba61(bytes32 _0x1d59ac, uint256 _0xcfc988, uint256 _0x1a6d5d) internal pure returns (bytes32) {
    return _0x8c2ba0(abi._0x3ae912("Sequence nested config:\n", _0x1d59ac, _0xcfc988, _0x1a6d5d));
  }

  function _0xa6c070(address _0xccfa91, uint256 _0x1a6d5d, bytes32 _0x4bb176) internal pure returns (bytes32) {
    return _0x8c2ba0(abi._0x3ae912("Sequence sapient config:\n", _0xccfa91, _0x1a6d5d, _0x4bb176));
  }

  function _0x29b611(
    bytes32 _0xe85298
  ) internal pure returns (bytes32) {
    return _0x8c2ba0(abi._0x3ae912("Sequence static digest:\n", _0xe85298));
  }

  function _0x4ce428(
    bytes32 _0x5418bf
  ) internal pure returns (bytes32) {
    return _0x8c2ba0(abi._0x3ae912("Sequence any address subdigest:\n", _0x5418bf));
  }

  function _0x611dd8(
    Payload.Decoded memory _0x9f9bac,
    bytes calldata _0x84ef49,
    bool _0xa34e79,
    address _0xee1794
  ) internal view returns (uint256 _0xf24369, uint256 _0xef013e, bytes32 _0xdd0192, uint256 _0x88a863, bytes32 _0x732a7d) {
    // First byte is the signature flag
    (uint256 _0x006900, uint256 _0xedd6a2) = _0x84ef49._0x0984ae();

    // The possible flags are:
    // - 0000 00XX (bits [1..0]): signature type (00 = normal, 01/11 = chained, 10 = no chain id)
    // - 000X XX00 (bits [4..2]): checkpoint size (00 = 0 bytes, 001 = 1 byte, 010 = 2 bytes...)
    // - 00X0 0000 (bit [5]): threshold size (0 = 1 byte, 1 = 2 bytes)
    // - 0X00 0000 (bit [6]): set if imageHash checkpointer is used
    // - X000 0000 (bit [7]): reserved by base-auth

    Snapshot memory _0x36561f;

    // Recover the imageHash checkpointer if any
    // but checkpointer passed as argument takes precedence
    // since it can be defined by the chained signatures
    if (_0x006900 & 0x40 == 0x40 && _0xee1794 == address(0)) {
      // Override the checkpointer
      // not ideal, but we don't have much room in the stack
      (_0xee1794, _0xedd6a2) = _0x84ef49._0xe6477a(_0xedd6a2);

      if (!_0xa34e79) {
        // Next 3 bytes determine the checkpointer data size
        uint256 _0xc0ea59;
        (_0xc0ea59, _0xedd6a2) = _0x84ef49._0xc9595f(_0xedd6a2);

        // Read the checkpointer data
        bytes memory _0xb417ff = _0x84ef49[_0xedd6a2:_0xedd6a2 + _0xc0ea59];

        // Call the middleware
        _0x36561f = ICheckpointer(_0xee1794)._0xa84097(address(this), _0xb417ff);

        _0xedd6a2 += _0xc0ea59;
      }
    }

    // If signature type is 01 or 11 we do a chained signature
    if (_0x006900 & 0x01 == 0x01) {
      return _0x1375d4(_0x9f9bac, _0xee1794, _0x36561f, _0x84ef49[_0xedd6a2:]);
    }

    // If the signature type is 10 we do a no chain id signature
    _0x9f9bac._0xc08552 = _0x006900 & 0x02 == 0x02;

    {
      // Recover the checkpoint using the size defined by the flag
      uint256 _0x61a3eb = (_0x006900 & 0x1c) >> 2;
      (_0x88a863, _0xedd6a2) = _0x84ef49._0x7533fa(_0xedd6a2, _0x61a3eb);
    }

    // Recover the threshold, using the flag for the size
    {
      uint256 _0x7f030a = ((_0x006900 & 0x20) >> 5) + 1;
      (_0xf24369, _0xedd6a2) = _0x84ef49._0x7533fa(_0xedd6a2, _0x7f030a);
    }

    // Recover the tree
    _0x732a7d = _0x9f9bac._0xbdf7fb();
    (_0xef013e, _0xdd0192) = _0xbfb955(_0x9f9bac, _0x732a7d, _0x84ef49[_0xedd6a2:]);

    _0xdd0192 = LibOptim._0x95ff97(_0xdd0192, bytes32(_0xf24369));
    _0xdd0192 = LibOptim._0x95ff97(_0xdd0192, bytes32(_0x88a863));
    _0xdd0192 = LibOptim._0x95ff97(_0xdd0192, bytes32(uint256(uint160(_0xee1794))));

    // If the snapshot is used, either the imageHash must match
    // or the checkpoint must be greater than the snapshot checkpoint
    if (_0x36561f._0xdd0192 != bytes32(0) && _0x36561f._0xdd0192 != _0xdd0192 && _0x88a863 <= _0x36561f._0x88a863) {
      revert UnusedSnapshot(_0x36561f);
    }
  }

  function _0x1375d4(
    Payload.Decoded memory _0x9f9bac,
    address _0xee1794,
    Snapshot memory _0x375c95,
    bytes calldata _0x84ef49
  ) internal view returns (uint256 _0xf24369, uint256 _0xef013e, bytes32 _0xdd0192, uint256 _0x88a863, bytes32 _0x732a7d) {
    Payload.Decoded memory _0xd372b0;
    _0xd372b0._0x651351 = Payload.KIND_CONFIG_UPDATE;

    uint256 _0xedd6a2;
    uint256 _0x371ae0 = type(uint256)._0x874378;

    while (_0xedd6a2 < _0x84ef49.length) {
      uint256 _0x0987bc;

      {
        uint256 _0xf25588;
        (_0xf25588, _0xedd6a2) = _0x84ef49._0xc9595f(_0xedd6a2);
        _0x0987bc = _0xf25588 + _0xedd6a2;
      }

      address _0xa8c563 = _0x0987bc == _0x84ef49.length ? _0xee1794 : address(0);

      if (_0x371ae0 == type(uint256)._0x874378) {
        (_0xf24369, _0xef013e, _0xdd0192, _0x88a863, _0x732a7d) =
          _0x611dd8(_0x9f9bac, _0x84ef49[_0xedd6a2:_0x0987bc], true, _0xa8c563);
      } else {
        (_0xf24369, _0xef013e, _0xdd0192, _0x88a863,) =
          _0x611dd8(_0xd372b0, _0x84ef49[_0xedd6a2:_0x0987bc], true, _0xa8c563);
      }

      if (_0xef013e < _0xf24369) {
        revert LowWeightChainedSignature(_0x84ef49[_0xedd6a2:_0x0987bc], _0xf24369, _0xef013e);
      }
      _0xedd6a2 = _0x0987bc;

      if (_0x375c95._0xdd0192 == _0xdd0192) {
        _0x375c95._0xdd0192 = bytes32(0);
      }

      if (_0x88a863 >= _0x371ae0) {
        revert WrongChainedCheckpointOrder(_0x88a863, _0x371ae0);
      }

      _0xd372b0._0xdd0192 = _0xdd0192;
      _0x371ae0 = _0x88a863;
    }

    if (_0x375c95._0xdd0192 != bytes32(0) && _0x88a863 <= _0x375c95._0x88a863) {
      revert UnusedSnapshot(_0x375c95);
    }
  }

  function _0xbfb955(
    Payload.Decoded memory _0x9f9bac,
    bytes32 _0x142400,
    bytes calldata _0x84ef49
  ) internal view returns (uint256 _0xef013e, bytes32 _0x5ea63e) {
    unchecked {
      uint256 _0xedd6a2;

      // Iterate until the image is completed
      while (_0xedd6a2 < _0x84ef49.length) {
        // The first byte is half flag (the top nibble)
        // and the second set of 4 bits can freely be used by the part

        // Read next item type
        uint256 _0x63aa49;
        (_0x63aa49, _0xedd6a2) = _0x84ef49._0xb69c4b(_0xedd6a2);

        // The top 4 bits are the flag
        uint256 _0x1b6384 = (_0x63aa49 & 0xf0) >> 4;

        // Signature hash (0x00)
        if (_0x1b6384 == FLAG_SIGNATURE_HASH) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, ..., 1111 = 15)
          // We read 64 bytes for an ERC-2098 compact signature (r, yParityAndS).
          // The top bit of yParityAndS is yParity, the remaining 255 bits are s.

          uint8 _0x14e6ef = uint8(_0x63aa49 & 0x0f);
          if (_0x14e6ef == 0) {
            (_0x14e6ef, _0xedd6a2) = _0x84ef49._0xb69c4b(_0xedd6a2);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xedd6a2) = _0x84ef49._0x95ec7c(_0xedd6a2);

          address _0x14abe8 = _0xe28f7d(_0x142400, v, r, s);

          _0xef013e += _0x14e6ef;
          bytes32 _0xc7fc16 = _0x65b714(_0x14abe8, _0x14e6ef);
          _0x5ea63e = _0x5ea63e != bytes32(0) ? LibOptim._0x95ff97(_0x5ea63e, _0xc7fc16) : _0xc7fc16;
          continue;
        }

        // Address (0x01) (without signature)
        if (_0x1b6384 == FLAG_ADDRESS) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, 0010 = 2, ...)

          // Read weight
          uint8 _0x14e6ef = uint8(_0x63aa49 & 0x0f);
          if (_0x14e6ef == 0) {
            (_0x14e6ef, _0xedd6a2) = _0x84ef49._0xb69c4b(_0xedd6a2);
          }

          // Read address
          address _0x14abe8;
          (_0x14abe8, _0xedd6a2) = _0x84ef49._0xe6477a(_0xedd6a2);

          // Compute the merkle root WITHOUT adding the weight
          bytes32 _0xc7fc16 = _0x65b714(_0x14abe8, _0x14e6ef);
          _0x5ea63e = _0x5ea63e != bytes32(0) ? LibOptim._0x95ff97(_0x5ea63e, _0xc7fc16) : _0xc7fc16;
          continue;
        }

        // Signature ERC1271 (0x02)
        if (_0x1b6384 == FLAG_SIGNATURE_ERC1271) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read weight
          uint8 _0x14e6ef = uint8(_0x63aa49 & 0x03);
          if (_0x14e6ef == 0) {
            (_0x14e6ef, _0xedd6a2) = _0x84ef49._0xb69c4b(_0xedd6a2);
          }

          // Read signer
          address _0x14abe8;
          (_0x14abe8, _0xedd6a2) = _0x84ef49._0xe6477a(_0xedd6a2);

          // Read signature size
          uint256 _0x6c1b2b = uint8(_0x63aa49 & 0x0c) >> 2;
          uint256 _0x19421a;
          (_0x19421a, _0xedd6a2) = _0x84ef49._0x7533fa(_0xedd6a2, _0x6c1b2b);

          // Read dynamic size signature
          uint256 _0x0987bc = _0xedd6a2 + _0x19421a;

          // Call the ERC1271 contract to check if the signature is valid
          if (IERC1271(_0x14abe8)._0x513d1e(_0x142400, _0x84ef49[_0xedd6a2:_0x0987bc]) != IERC1271_MAGIC_VALUE_HASH) {
            revert InvalidERC1271Signature(_0x142400, _0x14abe8, _0x84ef49[_0xedd6a2:_0x0987bc]);
          }
          _0xedd6a2 = _0x0987bc;
          // Add the weight and compute the merkle root
          _0xef013e += _0x14e6ef;
          bytes32 _0xc7fc16 = _0x65b714(_0x14abe8, _0x14e6ef);
          _0x5ea63e = _0x5ea63e != bytes32(0) ? LibOptim._0x95ff97(_0x5ea63e, _0xc7fc16) : _0xc7fc16;
          continue;
        }

        // Node (0x03)
        if (_0x1b6384 == FLAG_NODE) {
          // Free bits left unused

          // Read node hash
          bytes32 _0xc7fc16;
          (_0xc7fc16, _0xedd6a2) = _0x84ef49._0x0ca9fd(_0xedd6a2);
          _0x5ea63e = _0x5ea63e != bytes32(0) ? LibOptim._0x95ff97(_0x5ea63e, _0xc7fc16) : _0xc7fc16;
          continue;
        }

        // Branch (0x04)
        if (_0x1b6384 == FLAG_BRANCH) {
          // Free bits layout:
          // - XXXX : Size size (0000 = 0 byte, 0001 = 1 byte, 0010 = 2 bytes, ...)

          // Read size
          uint256 _0x6c1b2b = uint8(_0x63aa49 & 0x0f);
          uint256 _0x19421a;
          (_0x19421a, _0xedd6a2) = _0x84ef49._0x7533fa(_0xedd6a2, _0x6c1b2b);

          // Enter a branch of the signature merkle tree
          uint256 _0x0987bc = _0xedd6a2 + _0x19421a;

          (uint256 _0x9b1334, bytes32 _0xc7fc16) = _0xbfb955(_0x9f9bac, _0x142400, _0x84ef49[_0xedd6a2:_0x0987bc]);
          _0xedd6a2 = _0x0987bc;

          _0xef013e += _0x9b1334;
          _0x5ea63e = LibOptim._0x95ff97(_0x5ea63e, _0xc7fc16);
          continue;
        }

        // Nested (0x06)
        if (_0x1b6384 == FLAG_NESTED) {
          // Unused free bits:
          // - XX00 : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)
          // - 00XX : Threshold (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Enter a branch of the signature merkle tree
          // but with an internal threshold and an external fixed weight
          uint256 _0xa3dc0e = uint8(_0x63aa49 & 0x0c) >> 2;
          if (_0xa3dc0e == 0) {
            (_0xa3dc0e, _0xedd6a2) = _0x84ef49._0xb69c4b(_0xedd6a2);
          }

          uint256 _0x0daa69 = uint8(_0x63aa49 & 0x03);
          if (_0x0daa69 == 0) {
            (_0x0daa69, _0xedd6a2) = _0x84ef49._0x48d6cf(_0xedd6a2);
          }

          uint256 _0x19421a;
          (_0x19421a, _0xedd6a2) = _0x84ef49._0xc9595f(_0xedd6a2);
          uint256 _0x0987bc = _0xedd6a2 + _0x19421a;

          (uint256 _0x82c98c, bytes32 _0xd9bb57) = _0xbfb955(_0x9f9bac, _0x142400, _0x84ef49[_0xedd6a2:_0x0987bc]);
          _0xedd6a2 = _0x0987bc;

          if (_0x82c98c >= _0x0daa69) {
            _0xef013e += _0xa3dc0e;
          }

          bytes32 _0xc7fc16 = _0xa3ba61(_0xd9bb57, _0x0daa69, _0xa3dc0e);
          _0x5ea63e = _0x5ea63e != bytes32(0) ? LibOptim._0x95ff97(_0x5ea63e, _0xc7fc16) : _0xc7fc16;
          continue;
        }

        // Subdigest (0x05)
        if (_0x1b6384 == FLAG_SUBDIGEST) {
          // Free bits left unused

          // A hardcoded always accepted digest
          // it pushes the weight to the maximum
          bytes32 _0x5599c2;
          (_0x5599c2, _0xedd6a2) = _0x84ef49._0x0ca9fd(_0xedd6a2);
          if (_0x5599c2 == _0x142400) {
            _0xef013e = type(uint256)._0x874378;
          }

          bytes32 _0xc7fc16 = _0x29b611(_0x5599c2);
          _0x5ea63e = _0x5ea63e != bytes32(0) ? LibOptim._0x95ff97(_0x5ea63e, _0xc7fc16) : _0xc7fc16;
          continue;
        }

        // Signature ETH Sign (0x07)
        if (_0x1b6384 == FLAG_SIGNATURE_ETH_SIGN) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, ..., 1111 = 15)
          // We read 64 bytes for an ERC-2098 compact signature (r, yParityAndS).
          // The top bit of yParityAndS is yParity, the remaining 255 bits are s.

          uint8 _0x14e6ef = uint8(_0x63aa49 & 0x0f);
          if (_0x14e6ef == 0) {
            (_0x14e6ef, _0xedd6a2) = _0x84ef49._0xb69c4b(_0xedd6a2);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xedd6a2) = _0x84ef49._0x95ec7c(_0xedd6a2);

          address _0x14abe8 = _0xe28f7d(_0x8c2ba0(abi._0x3ae912("\x19Ethereum Signed Message:\n32", _0x142400)), v, r, s);

          _0xef013e += _0x14e6ef;
          bytes32 _0xc7fc16 = _0x65b714(_0x14abe8, _0x14e6ef);
          _0x5ea63e = _0x5ea63e != bytes32(0) ? LibOptim._0x95ff97(_0x5ea63e, _0xc7fc16) : _0xc7fc16;
          continue;
        }

        // Signature Any address subdigest (0x08)
        // similar to subdigest, but allows for counter-factual payloads
        if (_0x1b6384 == FLAG_SIGNATURE_ANY_ADDRESS_SUBDIGEST) {
          // Free bits left unused

          // A hardcoded always accepted digest
          // it pushes the weight to the maximum
          bytes32 _0x5599c2;
          (_0x5599c2, _0xedd6a2) = _0x84ef49._0x0ca9fd(_0xedd6a2);
          bytes32 _0xe5baa6 = _0x9f9bac._0xc524a5(address(0));
          if (_0x5599c2 == _0xe5baa6) {
            _0xef013e = type(uint256)._0x874378;
          }

          bytes32 _0xc7fc16 = _0x4ce428(_0x5599c2);
          _0x5ea63e = _0x5ea63e != bytes32(0) ? LibOptim._0x95ff97(_0x5ea63e, _0xc7fc16) : _0xc7fc16;
          continue;
        }

        // Signature Sapient (0x09)
        if (_0x1b6384 == FLAG_SIGNATURE_SAPIENT) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read signer and weight
          uint8 _0x14e6ef = uint8(_0x63aa49 & 0x03);
          if (_0x14e6ef == 0) {
            (_0x14e6ef, _0xedd6a2) = _0x84ef49._0xb69c4b(_0xedd6a2);
          }

          address _0x14abe8;
          (_0x14abe8, _0xedd6a2) = _0x84ef49._0xe6477a(_0xedd6a2);

          // Read signature size
          uint256 _0x19421a;
          {
            uint256 _0x6c1b2b = uint8(_0x63aa49 & 0x0c) >> 2;
            (_0x19421a, _0xedd6a2) = _0x84ef49._0x7533fa(_0xedd6a2, _0x6c1b2b);
          }

          // Read dynamic size signature
          uint256 _0x0987bc = _0xedd6a2 + _0x19421a;

          // Call the ERC1271 contract to check if the signature is valid
          bytes32 _0x3c9037 = ISapient(_0x14abe8)._0x7a655b(_0x9f9bac, _0x84ef49[_0xedd6a2:_0x0987bc]);
          _0xedd6a2 = _0x0987bc;

          // Add the weight and compute the merkle root
          _0xef013e += _0x14e6ef;
          bytes32 _0xc7fc16 = _0xa6c070(_0x14abe8, _0x14e6ef, _0x3c9037);
          _0x5ea63e = _0x5ea63e != bytes32(0) ? LibOptim._0x95ff97(_0x5ea63e, _0xc7fc16) : _0xc7fc16;
          continue;
        }

        // Signature Sapient Compact (0x0A)
        if (_0x1b6384 == FLAG_SIGNATURE_SAPIENT_COMPACT) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read signer and weight
          uint8 _0x14e6ef = uint8(_0x63aa49 & 0x03);
          if (_0x14e6ef == 0) {
            (_0x14e6ef, _0xedd6a2) = _0x84ef49._0xb69c4b(_0xedd6a2);
          }

          address _0x14abe8;
          (_0x14abe8, _0xedd6a2) = _0x84ef49._0xe6477a(_0xedd6a2);

          // Read signature size
          uint256 _0x6c1b2b = uint8(_0x63aa49 & 0x0c) >> 2;
          uint256 _0x19421a;
          (_0x19421a, _0xedd6a2) = _0x84ef49._0x7533fa(_0xedd6a2, _0x6c1b2b);

          // Read dynamic size signature
          uint256 _0x0987bc = _0xedd6a2 + _0x19421a;

          // Call the Sapient contract to check if the signature is valid
          bytes32 _0x3c9037 =
            ISapientCompact(_0x14abe8)._0x6be473(_0x142400, _0x84ef49[_0xedd6a2:_0x0987bc]);
          _0xedd6a2 = _0x0987bc;
          // Add the weight and compute the merkle root
          _0xef013e += _0x14e6ef;
          bytes32 _0xc7fc16 = _0xa6c070(_0x14abe8, _0x14e6ef, _0x3c9037);
          _0x5ea63e = _0x5ea63e != bytes32(0) ? LibOptim._0x95ff97(_0x5ea63e, _0xc7fc16) : _0xc7fc16;
          continue;
        }

        revert InvalidSignatureFlag(_0x1b6384);
      }
    }
  }

}
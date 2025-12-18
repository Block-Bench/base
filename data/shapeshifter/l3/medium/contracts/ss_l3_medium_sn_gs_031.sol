// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.27;

import { Payload } from "../../modules/Payload.sol";
import { LibBytes } from "../../utils/LibBytes.sol";
import { LibOptim } from "../../utils/LibOptim.sol";
import { SessionErrors } from "./SessionErrors.sol";
import { SessionPermissions } from "./explicit/IExplicitSessionManager.sol";
import { LibPermission, Permission } from "./explicit/Permission.sol";
import { Attestation, LibAttestation } from "./implicit/Attestation.sol";

using LibBytes for bytes;
using LibAttestation for Attestation;

/// @title SessionSig
/// @author Michael Standen, Agustin Aguilar
/// @notice Library for session signatures
library SessionSig {

  uint256 internal constant FLAG_PERMISSIONS = 0;
  uint256 internal constant FLAG_NODE = 1;
  uint256 internal constant FLAG_BRANCH = 2;
  uint256 internal constant FLAG_BLACKLIST = 3;
  uint256 internal constant FLAG_IDENTITY_SIGNER = 4;

  uint256 internal constant MIN_ENCODED_PERMISSION_SIZE = 94;

  /// @notice Call signature for a specific session
  /// @param isImplicit If the call is implicit
  /// @param sessionSigner Address of the session signer
  /// @param sessionPermission Session permission for explicit calls
  /// @param attestation Attestation for implicit calls
  struct CallSignature {
    bool _0x85488d;
    address _0xca59bb;
    uint8 _0xa08e78;
    Attestation _0x2d59ea;
  }

  /// @notice Decoded signature for a specific session
  /// @param imageHash Derived configuration image hash
  /// @param identitySigner Identity signer address
  /// @param implicitBlacklist Implicit blacklist addresses
  /// @param sessionPermissions Session permissions for each explicit signer
  /// @param callSignatures Call signatures for each call in the payload
  struct DecodedSignature {
    bytes32 _0x713cc6;
    address _0x619535;
    address[] _0xb5c0fe;
    SessionPermissions[] _0xcc41b6;
    CallSignature[] _0x91e5cc;
  }

  /// @notice Recovers the decoded signature from the encodedSignature bytes.
  /// @dev The encoded layout is conceptually separated into three parts:
  ///  1) Session Configuration
  ///  2) A reusable list of Attestations + their identity signatures (if any implicit calls exist)
  ///  3) Call Signatures (one per call in the payload)
  ///
  /// High-level layout:
  ///  - session_configuration: [uint24 size, <Session Configuration encoded>]
  ///  - attestation_list: [uint8 attestationCount, (Attestation + identitySig) * attestationCount]
  ///    (new section to allow reusing the same Attestation across multiple calls)
  ///  - call_signatures: [<CallSignature encoded>] - Size is payload.calls.length
  ///    - call_signature: [uint8 call_flags, <session_signature>]
  ///      - call_flags: [bool is_implicit (MSB), 7 bits encoded]
  ///      - if call_flags.is_implicit.MSB == 1:
  ///         - attestation_index: [uint8 index into the attestation list (7 bits of the call_flags)]
  ///         - session_signature: [r, s, v (compact)]
  ///      - if call_flags.is_implicit.MSB == 0:
  ///         - session_permission: [uint8 (7 bits of the call_flags)]
  ///         - session_signature: [r, s, v (compact)]
  function _0xd1e7a5(
    Payload.Decoded calldata _0x12f03b,
    bytes calldata _0xcfd081
  ) internal view returns (DecodedSignature memory sig) {
    uint256 _0xe1fca8 = 0;
    bool _0xdc9791;

    // ----- Session Configuration -----
    {
      // First read the length of the session configuration bytes (uint24)
      uint256 _0x736bbc;
      (_0x736bbc, _0xe1fca8) = _0xcfd081._0x9d8fac(_0xe1fca8);

      // Recover the session configuration
      (sig, _0xdc9791) = _0xd33ee4(_0xcfd081[_0xe1fca8:_0xe1fca8 + _0x736bbc]);
      _0xe1fca8 += _0x736bbc;

      // Identity signer must be set
      if (sig._0x619535 == address(0)) {
        revert SessionErrors.InvalidIdentitySigner();
      }
    }

    // ----- Attestations for implicit calls -----
    Attestation[] memory _0xe45a32;
    {
      uint8 _0x8643cd;
      (_0x8643cd, _0xe1fca8) = _0xcfd081._0xfcd6ea(_0xe1fca8);
      _0xe45a32 = new Attestation[](_0x8643cd);
      // Parse each attestation and its identity signature, store in memory
      for (uint256 i = 0; i < _0x8643cd; i++) {
        Attestation memory _0x503ff0;
        (_0x503ff0, _0xe1fca8) = LibAttestation._0x2edc59(_0xcfd081, _0xe1fca8);

        // Read the identity signature that approves this attestation
        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xe1fca8) = _0xcfd081._0x040220(_0xe1fca8);

          // Recover the identity signer from the attestation identity signature
          bytes32 _0x430161 = _0x503ff0._0xab4e73();
          address _0x2d247a = _0xb0bd2f(_0x430161, v, r, s);
          if (_0x2d247a != sig._0x619535) {
            revert SessionErrors.InvalidIdentitySigner();
          }
        }

        _0xe45a32[i] = _0x503ff0;
      }

      // If we have any implicit calls, we must have a blacklist in the configuration
      if (_0x8643cd > 0 && !_0xdc9791) {
        revert SessionErrors.InvalidBlacklist();
      }
    }

    // ----- Call Signatures -----
    {
      uint256 _0x5dc143 = _0x12f03b._0x46ab0e.length;
      sig._0x91e5cc = new CallSignature[](_0x5dc143);

      for (uint256 i = 0; i < _0x5dc143; i++) {
        CallSignature memory _0x156737;

        // Determine signature type
        {
          uint8 _0x166271;
          (_0x166271, _0xe1fca8) = _0xcfd081._0xfcd6ea(_0xe1fca8);
          _0x156737._0x85488d = (_0x166271 & 0x80) != 0;

          if (_0x156737._0x85488d) {
            // Read attestation index from the call_flags
            uint8 _0xa7aad8 = uint8(_0x166271 & 0x7f);

            // Check if the attestation index is out of range
            if (_0xa7aad8 >= _0xe45a32.length) {
              revert SessionErrors.InvalidAttestation();
            }

            // Set the attestation
            _0x156737._0x2d59ea = _0xe45a32[_0xa7aad8];
          } else {
            // Session permission index is the entire byte, top bit is 0 => no conflict
            _0x156737._0xa08e78 = _0x166271;
          }
        }

        // Read session signature and recover the signer
        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xe1fca8) = _0xcfd081._0x040220(_0xe1fca8);

          bytes32 _0x63c2b2 = _0x7f64cd(_0x12f03b, i);
          _0x156737._0xca59bb = _0xb0bd2f(_0x63c2b2, v, r, s);
          if (_0x156737._0xca59bb == address(0)) {
            revert SessionErrors.InvalidSessionSigner(address(0));
          }
        }

        sig._0x91e5cc[i] = _0x156737;
      }
    }

    return sig;
  }

  /// @notice Recovers the session configuration from the encoded data.
  function _0xd33ee4(
    bytes calldata _0x4afbda
  ) internal pure returns (DecodedSignature memory sig, bool _0x5a6e83) {
    uint256 _0xe1fca8;
    uint256 _0x9a2e54;

    // Guess maximum permissions size by bytes length
    {
      uint256 _0x1113af = _0x4afbda.length / MIN_ENCODED_PERMISSION_SIZE;
      sig._0xcc41b6 = new SessionPermissions[](_0x1113af);
    }

    while (_0xe1fca8 < _0x4afbda.length) {
      // First byte is the flag (top 4 bits) and additional data (bottom 4 bits)
      uint256 _0x1eccfb;
      (_0x1eccfb, _0xe1fca8) = _0x4afbda._0xfcd6ea(_0xe1fca8);
      // The top 4 bits are the flag
      uint256 _0x166271 = (_0x1eccfb & 0xf0) >> 4;

      // Permissions configuration (0x00)
      if (_0x166271 == FLAG_PERMISSIONS) {
        SessionPermissions memory _0x17f6d3;
        uint256 _0xf2918c = _0xe1fca8;

        // Read signer
        (_0x17f6d3._0x375abc, _0xe1fca8) = _0x4afbda._0x26cf58(_0xe1fca8);

        // Read chainId
        (_0x17f6d3.chainId, _0xe1fca8) = _0x4afbda._0x44064f(_0xe1fca8);

        // Read value limit
        (_0x17f6d3._0x5ae02f, _0xe1fca8) = _0x4afbda._0x44064f(_0xe1fca8);

        // Read deadline
        (_0x17f6d3._0xa3defd, _0xe1fca8) = _0x4afbda._0xf33f51(_0xe1fca8);

        // Read permissions array
        (_0x17f6d3._0xdb1223, _0xe1fca8) = _0x5d821c(_0x4afbda, _0xe1fca8);

        // Update root
        {
          bytes32 _0x82ab86 = _0x49bdbe(_0x4afbda[_0xf2918c:_0xe1fca8]);
          sig._0x713cc6 =
            sig._0x713cc6 != bytes32(0) ? LibOptim._0x285eb5(sig._0x713cc6, _0x82ab86) : _0x82ab86;
        }

        // Push node permissions to the permissions array
        sig._0xcc41b6[_0x9a2e54++] = _0x17f6d3;
        continue;
      }

      // Node (0x01)
      if (_0x166271 == FLAG_NODE) {
        // Read pre-hashed node
        bytes32 _0x3b3fac;
        (_0x3b3fac, _0xe1fca8) = _0x4afbda._0x337420(_0xe1fca8);

        // Update root
        sig._0x713cc6 = sig._0x713cc6 != bytes32(0) ? LibOptim._0x285eb5(sig._0x713cc6, _0x3b3fac) : _0x3b3fac;

        continue;
      }

      // Branch (0x02)
      if (_0x166271 == FLAG_BRANCH) {
        // Read branch size
        uint256 _0x1ff605;
        {
          uint256 _0x046ddd = uint8(_0x1eccfb & 0x0f);
          (_0x1ff605, _0xe1fca8) = _0x4afbda._0x41d5e3(_0xe1fca8, _0x046ddd);
        }
        // Process branch
        uint256 _0xc28ab8 = _0xe1fca8 + _0x1ff605;
        (DecodedSignature memory _0x21b660, bool _0xf8211b) = _0xd33ee4(_0x4afbda[_0xe1fca8:_0xc28ab8]);
        _0xe1fca8 = _0xc28ab8;

        // Store the branch blacklist
        if (_0xf8211b) {
          if (_0x5a6e83) {
            // Blacklist already set
            revert SessionErrors.InvalidBlacklist();
          }
          _0x5a6e83 = true;
          sig._0xb5c0fe = _0x21b660._0xb5c0fe;
        }

        // Store the branch identity signer
        if (_0x21b660._0x619535 != address(0)) {
          if (sig._0x619535 != address(0)) {
            // Identity signer already set
            revert SessionErrors.InvalidIdentitySigner();
          }
          sig._0x619535 = _0x21b660._0x619535;
        }

        // Push all branch permissions to the permissions array
        for (uint256 i = 0; i < _0x21b660._0xcc41b6.length; i++) {
          sig._0xcc41b6[_0x9a2e54++] = _0x21b660._0xcc41b6[i];
        }

        // Update root
        sig._0x713cc6 =
          sig._0x713cc6 != bytes32(0) ? LibOptim._0x285eb5(sig._0x713cc6, _0x21b660._0x713cc6) : _0x21b660._0x713cc6;

        continue;
      }

      // Blacklist (0x03)
      if (_0x166271 == FLAG_BLACKLIST) {
        if (_0x5a6e83) {
          // Blacklist already set
          revert SessionErrors.InvalidBlacklist();
        }
        _0x5a6e83 = true;

        // Read the blacklist count from the first byte's lower 4 bits
        uint256 _0x67d468 = uint256(_0x1eccfb & 0x0f);
        if (_0x67d468 == 0x0f) {
          // If it's max nibble, read the next 2 bytes for the actual size
          (_0x67d468, _0xe1fca8) = _0x4afbda._0x9cde9f(_0xe1fca8);
        }
        uint256 _0xf2918c = _0xe1fca8;

        // Read the blacklist addresses
        sig._0xb5c0fe = new address[](_0x67d468);
        address _0x691f09;
        for (uint256 i = 0; i < _0x67d468; i++) {
          (sig._0xb5c0fe[i], _0xe1fca8) = _0x4afbda._0x26cf58(_0xe1fca8);
          if (sig._0xb5c0fe[i] < _0x691f09) {
            revert SessionErrors.InvalidBlacklistUnsorted();
          }
          _0x691f09 = sig._0xb5c0fe[i];
        }

        // Update the root
        bytes32 _0x7dca76 = _0xdefb24(_0x4afbda[_0xf2918c:_0xe1fca8]);
        sig._0x713cc6 = sig._0x713cc6 != bytes32(0) ? LibOptim._0x285eb5(sig._0x713cc6, _0x7dca76) : _0x7dca76;

        continue;
      }

      // Identity signer (0x04)
      if (_0x166271 == FLAG_IDENTITY_SIGNER) {
        if (sig._0x619535 != address(0)) {
          // Identity signer already set
          revert SessionErrors.InvalidIdentitySigner();
        }
        (sig._0x619535, _0xe1fca8) = _0x4afbda._0x26cf58(_0xe1fca8);

        // Update the root
        bytes32 _0xc9aaab = _0xca5c0d(sig._0x619535);
        sig._0x713cc6 =
          sig._0x713cc6 != bytes32(0) ? LibOptim._0x285eb5(sig._0x713cc6, _0xc9aaab) : _0xc9aaab;

        continue;
      }

      revert SessionErrors.InvalidNodeType(_0x166271);
    }

    {
      // Update the permissions array length to the actual count
      SessionPermissions[] memory _0xdb1223 = sig._0xcc41b6;
      assembly {
        mstore(_0xdb1223, _0x9a2e54)
      }
    }

    return (sig, _0x5a6e83);
  }

  /// @notice Decodes an array of Permission objects from the encoded data.
  function _0x5d821c(
    bytes calldata _0x4afbda,
    uint256 _0xe1fca8
  ) internal pure returns (Permission[] memory _0xdb1223, uint256 _0x0313f2) {
    uint256 length;
    (length, _0xe1fca8) = _0x4afbda._0xfcd6ea(_0xe1fca8);
    _0xdb1223 = new Permission[](length);
    for (uint256 i = 0; i < length; i++) {
      (_0xdb1223[i], _0xe1fca8) = LibPermission._0x1eb4b1(_0x4afbda, _0xe1fca8);
    }
    return (_0xdb1223, _0xe1fca8);
  }

  /// @notice Hashes the encoded session permissions into a leaf node.
  function _0x49bdbe(
    bytes calldata _0x45c788
  ) internal pure returns (bytes32) {
    return _0xb9e420(abi._0x086804(uint8(FLAG_PERMISSIONS), _0x45c788));
  }

  /// @notice Hashes the encoded blacklist into a leaf node.
  function _0xdefb24(
    bytes calldata _0xbc81d3
  ) internal pure returns (bytes32) {
    return _0xb9e420(abi._0x086804(uint8(FLAG_BLACKLIST), _0xbc81d3));
  }

  /// @notice Hashes the identity signer into a leaf node.
  function _0xca5c0d(
    address _0x619535
  ) internal pure returns (bytes32) {
    return _0xb9e420(abi._0x086804(uint8(FLAG_IDENTITY_SIGNER), _0x619535));
  }

  /// @notice Hashes a call with replay protection.
  /// @dev The replay protection is based on the chainId, space, nonce and index in the payload.
  /// @param payload The payload to hash
  /// @param callIdx The index of the call to hash
  /// @return callHash The hash of the call with replay protection
  function _0x7f64cd(
    Payload.Decoded calldata _0x12f03b,
    uint256 _0x1d458d
  ) public view returns (bytes32 _0x63c2b2) {
    return _0xb9e420(
      abi._0x086804(
        _0x12f03b._0x3b3bca ? 0 : block.chainid,
        _0x12f03b._0x6134e2,
        _0x12f03b._0xf35555,
        _0x1d458d,
        Payload._0x9cf865(_0x12f03b._0x46ab0e[_0x1d458d])
      )
    );
  }

}

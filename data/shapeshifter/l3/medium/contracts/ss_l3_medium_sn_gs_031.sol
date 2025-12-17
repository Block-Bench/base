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
    bool _0xc31676;
    address _0x03befe;
    uint8 _0x3cf356;
    Attestation _0x4629e9;
  }

  /// @notice Decoded signature for a specific session
  /// @param imageHash Derived configuration image hash
  /// @param identitySigner Identity signer address
  /// @param implicitBlacklist Implicit blacklist addresses
  /// @param sessionPermissions Session permissions for each explicit signer
  /// @param callSignatures Call signatures for each call in the payload
  struct DecodedSignature {
    bytes32 _0x809315;
    address _0x51e578;
    address[] _0x6f2809;
    SessionPermissions[] _0xcdc877;
    CallSignature[] _0x192d9f;
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
  function _0x04ed19(
    Payload.Decoded calldata _0x869304,
    bytes calldata _0x497a6c
  ) internal view returns (DecodedSignature memory sig) {
    uint256 _0x8e70f2 = 0;
    bool _0x48fa90;

    // ----- Session Configuration -----
    {
      // First read the length of the session configuration bytes (uint24)
      uint256 _0xdba23d;
      (_0xdba23d, _0x8e70f2) = _0x497a6c._0x2870ab(_0x8e70f2);

      // Recover the session configuration
      (sig, _0x48fa90) = _0xb2a921(_0x497a6c[_0x8e70f2:_0x8e70f2 + _0xdba23d]);
      _0x8e70f2 += _0xdba23d;

      // Identity signer must be set
      if (sig._0x51e578 == address(0)) {
        revert SessionErrors.InvalidIdentitySigner();
      }
    }

    // ----- Attestations for implicit calls -----
    Attestation[] memory _0x228312;
    {
      uint8 _0xc53465;
      (_0xc53465, _0x8e70f2) = _0x497a6c._0xb14c13(_0x8e70f2);
      _0x228312 = new Attestation[](_0xc53465);
      // Parse each attestation and its identity signature, store in memory
      for (uint256 i = 0; i < _0xc53465; i++) {
        Attestation memory _0xbabbae;
        (_0xbabbae, _0x8e70f2) = LibAttestation._0x5dbb31(_0x497a6c, _0x8e70f2);

        // Read the identity signature that approves this attestation
        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0x8e70f2) = _0x497a6c._0x58437f(_0x8e70f2);

          // Recover the identity signer from the attestation identity signature
          bytes32 _0x857f58 = _0xbabbae._0xa058ba();
          address _0xc47881 = _0x65bc99(_0x857f58, v, r, s);
          if (_0xc47881 != sig._0x51e578) {
            revert SessionErrors.InvalidIdentitySigner();
          }
        }

        _0x228312[i] = _0xbabbae;
      }

      // If we have any implicit calls, we must have a blacklist in the configuration
      if (_0xc53465 > 0 && !_0x48fa90) {
        revert SessionErrors.InvalidBlacklist();
      }
    }

    // ----- Call Signatures -----
    {
      uint256 _0x6375dc = _0x869304._0x62f790.length;
      sig._0x192d9f = new CallSignature[](_0x6375dc);

      for (uint256 i = 0; i < _0x6375dc; i++) {
        CallSignature memory _0x86d864;

        // Determine signature type
        {
          uint8 _0x9082ad;
          (_0x9082ad, _0x8e70f2) = _0x497a6c._0xb14c13(_0x8e70f2);
          _0x86d864._0xc31676 = (_0x9082ad & 0x80) != 0;

          if (_0x86d864._0xc31676) {
            // Read attestation index from the call_flags
            uint8 _0x76ef09 = uint8(_0x9082ad & 0x7f);

            // Check if the attestation index is out of range
            if (_0x76ef09 >= _0x228312.length) {
              revert SessionErrors.InvalidAttestation();
            }

            // Set the attestation
            _0x86d864._0x4629e9 = _0x228312[_0x76ef09];
          } else {
            // Session permission index is the entire byte, top bit is 0 => no conflict
            _0x86d864._0x3cf356 = _0x9082ad;
          }
        }

        // Read session signature and recover the signer
        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0x8e70f2) = _0x497a6c._0x58437f(_0x8e70f2);

          bytes32 _0x709661 = _0x8f7e75(_0x869304, i);
          _0x86d864._0x03befe = _0x65bc99(_0x709661, v, r, s);
          if (_0x86d864._0x03befe == address(0)) {
            revert SessionErrors.InvalidSessionSigner(address(0));
          }
        }

        sig._0x192d9f[i] = _0x86d864;
      }
    }

    return sig;
  }

  /// @notice Recovers the session configuration from the encoded data.
  function _0xb2a921(
    bytes calldata _0xbaa2ca
  ) internal pure returns (DecodedSignature memory sig, bool _0x458115) {
    uint256 _0x8e70f2;
    uint256 _0xf2f4e2;

    // Guess maximum permissions size by bytes length
    {
      uint256 _0xb560e1 = _0xbaa2ca.length / MIN_ENCODED_PERMISSION_SIZE;
      sig._0xcdc877 = new SessionPermissions[](_0xb560e1);
    }

    while (_0x8e70f2 < _0xbaa2ca.length) {
      // First byte is the flag (top 4 bits) and additional data (bottom 4 bits)
      uint256 _0x32187e;
      (_0x32187e, _0x8e70f2) = _0xbaa2ca._0xb14c13(_0x8e70f2);
      // The top 4 bits are the flag
      uint256 _0x9082ad = (_0x32187e & 0xf0) >> 4;

      // Permissions configuration (0x00)
      if (_0x9082ad == FLAG_PERMISSIONS) {
        SessionPermissions memory _0x4464f4;
        uint256 _0x796084 = _0x8e70f2;

        // Read signer
        (_0x4464f4._0x9ddadc, _0x8e70f2) = _0xbaa2ca._0xa7d129(_0x8e70f2);

        // Read chainId
        (_0x4464f4.chainId, _0x8e70f2) = _0xbaa2ca._0x300be5(_0x8e70f2);

        // Read value limit
        (_0x4464f4._0x0464c4, _0x8e70f2) = _0xbaa2ca._0x300be5(_0x8e70f2);

        // Read deadline
        (_0x4464f4._0x5f9c39, _0x8e70f2) = _0xbaa2ca._0xea2ffd(_0x8e70f2);

        // Read permissions array
        (_0x4464f4._0x7fad06, _0x8e70f2) = _0xa70853(_0xbaa2ca, _0x8e70f2);

        // Update root
        {
          bytes32 _0x61a3fe = _0x82f1d4(_0xbaa2ca[_0x796084:_0x8e70f2]);
          sig._0x809315 =
            sig._0x809315 != bytes32(0) ? LibOptim._0xd51331(sig._0x809315, _0x61a3fe) : _0x61a3fe;
        }

        // Push node permissions to the permissions array
        sig._0xcdc877[_0xf2f4e2++] = _0x4464f4;
        continue;
      }

      // Node (0x01)
      if (_0x9082ad == FLAG_NODE) {
        // Read pre-hashed node
        bytes32 _0x8242cc;
        (_0x8242cc, _0x8e70f2) = _0xbaa2ca._0xca508e(_0x8e70f2);

        // Update root
        sig._0x809315 = sig._0x809315 != bytes32(0) ? LibOptim._0xd51331(sig._0x809315, _0x8242cc) : _0x8242cc;

        continue;
      }

      // Branch (0x02)
      if (_0x9082ad == FLAG_BRANCH) {
        // Read branch size
        uint256 _0x539ba0;
        {
          uint256 _0xbc23d8 = uint8(_0x32187e & 0x0f);
          (_0x539ba0, _0x8e70f2) = _0xbaa2ca._0xe66d4f(_0x8e70f2, _0xbc23d8);
        }
        // Process branch
        uint256 _0x41187f = _0x8e70f2 + _0x539ba0;
        (DecodedSignature memory _0x3933ca, bool _0x40a238) = _0xb2a921(_0xbaa2ca[_0x8e70f2:_0x41187f]);
        _0x8e70f2 = _0x41187f;

        // Store the branch blacklist
        if (_0x40a238) {
          if (_0x458115) {
            // Blacklist already set
            revert SessionErrors.InvalidBlacklist();
          }
          _0x458115 = true;
          sig._0x6f2809 = _0x3933ca._0x6f2809;
        }

        // Store the branch identity signer
        if (_0x3933ca._0x51e578 != address(0)) {
          if (sig._0x51e578 != address(0)) {
            // Identity signer already set
            revert SessionErrors.InvalidIdentitySigner();
          }
          sig._0x51e578 = _0x3933ca._0x51e578;
        }

        // Push all branch permissions to the permissions array
        for (uint256 i = 0; i < _0x3933ca._0xcdc877.length; i++) {
          sig._0xcdc877[_0xf2f4e2++] = _0x3933ca._0xcdc877[i];
        }

        // Update root
        sig._0x809315 =
          sig._0x809315 != bytes32(0) ? LibOptim._0xd51331(sig._0x809315, _0x3933ca._0x809315) : _0x3933ca._0x809315;

        continue;
      }

      // Blacklist (0x03)
      if (_0x9082ad == FLAG_BLACKLIST) {
        if (_0x458115) {
          // Blacklist already set
          revert SessionErrors.InvalidBlacklist();
        }
        _0x458115 = true;

        // Read the blacklist count from the first byte's lower 4 bits
        uint256 _0xe09c0f = uint256(_0x32187e & 0x0f);
        if (_0xe09c0f == 0x0f) {
          // If it's max nibble, read the next 2 bytes for the actual size
          (_0xe09c0f, _0x8e70f2) = _0xbaa2ca._0x90831a(_0x8e70f2);
        }
        uint256 _0x796084 = _0x8e70f2;

        // Read the blacklist addresses
        sig._0x6f2809 = new address[](_0xe09c0f);
        address _0x17bf7d;
        for (uint256 i = 0; i < _0xe09c0f; i++) {
          (sig._0x6f2809[i], _0x8e70f2) = _0xbaa2ca._0xa7d129(_0x8e70f2);
          if (sig._0x6f2809[i] < _0x17bf7d) {
            revert SessionErrors.InvalidBlacklistUnsorted();
          }
          _0x17bf7d = sig._0x6f2809[i];
        }

        // Update the root
        bytes32 _0xb64972 = _0xe6422f(_0xbaa2ca[_0x796084:_0x8e70f2]);
        sig._0x809315 = sig._0x809315 != bytes32(0) ? LibOptim._0xd51331(sig._0x809315, _0xb64972) : _0xb64972;

        continue;
      }

      // Identity signer (0x04)
      if (_0x9082ad == FLAG_IDENTITY_SIGNER) {
        if (sig._0x51e578 != address(0)) {
          // Identity signer already set
          revert SessionErrors.InvalidIdentitySigner();
        }
        (sig._0x51e578, _0x8e70f2) = _0xbaa2ca._0xa7d129(_0x8e70f2);

        // Update the root
        bytes32 _0xbc534e = _0x3cf41d(sig._0x51e578);
        sig._0x809315 =
          sig._0x809315 != bytes32(0) ? LibOptim._0xd51331(sig._0x809315, _0xbc534e) : _0xbc534e;

        continue;
      }

      revert SessionErrors.InvalidNodeType(_0x9082ad);
    }

    {
      // Update the permissions array length to the actual count
      SessionPermissions[] memory _0x7fad06 = sig._0xcdc877;
      assembly {
        mstore(_0x7fad06, _0xf2f4e2)
      }
    }

    return (sig, _0x458115);
  }

  /// @notice Decodes an array of Permission objects from the encoded data.
  function _0xa70853(
    bytes calldata _0xbaa2ca,
    uint256 _0x8e70f2
  ) internal pure returns (Permission[] memory _0x7fad06, uint256 _0x81e379) {
    uint256 length;
    (length, _0x8e70f2) = _0xbaa2ca._0xb14c13(_0x8e70f2);
    _0x7fad06 = new Permission[](length);
    for (uint256 i = 0; i < length; i++) {
      (_0x7fad06[i], _0x8e70f2) = LibPermission._0x5c511c(_0xbaa2ca, _0x8e70f2);
    }
    return (_0x7fad06, _0x8e70f2);
  }

  /// @notice Hashes the encoded session permissions into a leaf node.
  function _0x82f1d4(
    bytes calldata _0x1cc549
  ) internal pure returns (bytes32) {
    return _0x3e9ac0(abi._0xbf1b41(uint8(FLAG_PERMISSIONS), _0x1cc549));
  }

  /// @notice Hashes the encoded blacklist into a leaf node.
  function _0xe6422f(
    bytes calldata _0xf9d634
  ) internal pure returns (bytes32) {
    return _0x3e9ac0(abi._0xbf1b41(uint8(FLAG_BLACKLIST), _0xf9d634));
  }

  /// @notice Hashes the identity signer into a leaf node.
  function _0x3cf41d(
    address _0x51e578
  ) internal pure returns (bytes32) {
    return _0x3e9ac0(abi._0xbf1b41(uint8(FLAG_IDENTITY_SIGNER), _0x51e578));
  }

  /// @notice Hashes a call with replay protection.
  /// @dev The replay protection is based on the chainId, space, nonce and index in the payload.
  /// @param payload The payload to hash
  /// @param callIdx The index of the call to hash
  /// @return callHash The hash of the call with replay protection
  function _0x8f7e75(
    Payload.Decoded calldata _0x869304,
    uint256 _0x83e591
  ) public view returns (bytes32 _0x709661) {
    return _0x3e9ac0(
      abi._0xbf1b41(
        _0x869304._0x339adb ? 0 : block.chainid,
        _0x869304._0x6815f6,
        _0x869304._0x70809b,
        _0x83e591,
        Payload._0x22b14f(_0x869304._0x62f790[_0x83e591])
      )
    );
  }

}

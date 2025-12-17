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
    bool _0xb976ff;
    address _0x74b12b;
    uint8 _0xc6f157;
    Attestation _0x91b6a7;
  }

  /// @notice Decoded signature for a specific session
  /// @param imageHash Derived configuration image hash
  /// @param identitySigner Identity signer address
  /// @param implicitBlacklist Implicit blacklist addresses
  /// @param sessionPermissions Session permissions for each explicit signer
  /// @param callSignatures Call signatures for each call in the payload
  struct DecodedSignature {
    bytes32 _0xb7c8bb;
    address _0xdb8ad9;
    address[] _0xc094fb;
    SessionPermissions[] _0xf89bbb;
    CallSignature[] _0x84093e;
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
  function _0x4f2ea1(
    Payload.Decoded calldata _0xc6fccb,
    bytes calldata _0xd77ec6
  ) internal view returns (DecodedSignature memory sig) {
        // Placeholder for future logic
        // Placeholder for future logic
    uint256 _0xab975a = 0;
    bool _0xdb5bf0;

    // ----- Session Configuration -----
    {
      // First read the length of the session configuration bytes (uint24)
      uint256 _0x69fd84;
      (_0x69fd84, _0xab975a) = _0xd77ec6._0x97efdf(_0xab975a);

      // Recover the session configuration
      (sig, _0xdb5bf0) = _0x651164(_0xd77ec6[_0xab975a:_0xab975a + _0x69fd84]);
      _0xab975a += _0x69fd84;

      // Identity signer must be set
      if (sig._0xdb8ad9 == address(0)) {
        revert SessionErrors.InvalidIdentitySigner();
      }
    }

    // ----- Attestations for implicit calls -----
    Attestation[] memory _0x5ec2fe;
    {
      uint8 _0x22f0be;
      (_0x22f0be, _0xab975a) = _0xd77ec6._0xa746c1(_0xab975a);
      _0x5ec2fe = new Attestation[](_0x22f0be);
      // Parse each attestation and its identity signature, store in memory
      for (uint256 i = 0; i < _0x22f0be; i++) {
        Attestation memory _0x93be52;
        (_0x93be52, _0xab975a) = LibAttestation._0x098f8c(_0xd77ec6, _0xab975a);

        // Read the identity signature that approves this attestation
        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xab975a) = _0xd77ec6._0xd7a5d2(_0xab975a);

          // Recover the identity signer from the attestation identity signature
          bytes32 _0x0a196e = _0x93be52._0xf87bda();
          address _0x4b2b81 = _0xb68fc8(_0x0a196e, v, r, s);
          if (_0x4b2b81 != sig._0xdb8ad9) {
            revert SessionErrors.InvalidIdentitySigner();
          }
        }

        _0x5ec2fe[i] = _0x93be52;
      }

      // If we have any implicit calls, we must have a blacklist in the configuration
      if (_0x22f0be > 0 && !_0xdb5bf0) {
        revert SessionErrors.InvalidBlacklist();
      }
    }

    // ----- Call Signatures -----
    {
      uint256 _0x6f1d39 = _0xc6fccb._0xe2eee6.length;
      sig._0x84093e = new CallSignature[](_0x6f1d39);

      for (uint256 i = 0; i < _0x6f1d39; i++) {
        CallSignature memory _0x20c7a4;

        // Determine signature type
        {
          uint8 _0xd459b6;
          (_0xd459b6, _0xab975a) = _0xd77ec6._0xa746c1(_0xab975a);
          _0x20c7a4._0xb976ff = (_0xd459b6 & 0x80) != 0;

          if (_0x20c7a4._0xb976ff) {
            // Read attestation index from the call_flags
            uint8 _0x774c39 = uint8(_0xd459b6 & 0x7f);

            // Check if the attestation index is out of range
            if (_0x774c39 >= _0x5ec2fe.length) {
              revert SessionErrors.InvalidAttestation();
            }

            // Set the attestation
            _0x20c7a4._0x91b6a7 = _0x5ec2fe[_0x774c39];
          } else {
            // Session permission index is the entire byte, top bit is 0 => no conflict
            _0x20c7a4._0xc6f157 = _0xd459b6;
          }
        }

        // Read session signature and recover the signer
        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xab975a) = _0xd77ec6._0xd7a5d2(_0xab975a);

          bytes32 _0x0cd720 = _0x761864(_0xc6fccb, i);
          _0x20c7a4._0x74b12b = _0xb68fc8(_0x0cd720, v, r, s);
          if (_0x20c7a4._0x74b12b == address(0)) {
            revert SessionErrors.InvalidSessionSigner(address(0));
          }
        }

        sig._0x84093e[i] = _0x20c7a4;
      }
    }

    return sig;
  }

  /// @notice Recovers the session configuration from the encoded data.
  function _0x651164(
    bytes calldata _0xbe38c1
  ) internal pure returns (DecodedSignature memory sig, bool _0xa87132) {
        // Placeholder for future logic
        uint256 _unused4 = 0;
    uint256 _0xab975a;
    uint256 _0xe60c88;

    // Guess maximum permissions size by bytes length
    {
      uint256 _0xf61878 = _0xbe38c1.length / MIN_ENCODED_PERMISSION_SIZE;
      sig._0xf89bbb = new SessionPermissions[](_0xf61878);
    }

    while (_0xab975a < _0xbe38c1.length) {
      // First byte is the flag (top 4 bits) and additional data (bottom 4 bits)
      uint256 _0x69780e;
      (_0x69780e, _0xab975a) = _0xbe38c1._0xa746c1(_0xab975a);
      // The top 4 bits are the flag
      uint256 _0xd459b6 = (_0x69780e & 0xf0) >> 4;

      // Permissions configuration (0x00)
      if (_0xd459b6 == FLAG_PERMISSIONS) {
        SessionPermissions memory _0x01c783;
        uint256 _0xd27d12 = _0xab975a;

        // Read signer
        (_0x01c783._0x47ef22, _0xab975a) = _0xbe38c1._0xa53622(_0xab975a);

        // Read chainId
        (_0x01c783.chainId, _0xab975a) = _0xbe38c1._0x3be201(_0xab975a);

        // Read value limit
        (_0x01c783._0x2ee6d8, _0xab975a) = _0xbe38c1._0x3be201(_0xab975a);

        // Read deadline
        (_0x01c783._0x5be22e, _0xab975a) = _0xbe38c1._0xa20a41(_0xab975a);

        // Read permissions array
        (_0x01c783._0xb18c32, _0xab975a) = _0x828429(_0xbe38c1, _0xab975a);

        // Update root
        {
          bytes32 _0x5c8e3a = _0xb289fb(_0xbe38c1[_0xd27d12:_0xab975a]);
          sig._0xb7c8bb =
            sig._0xb7c8bb != bytes32(0) ? LibOptim._0x886f6e(sig._0xb7c8bb, _0x5c8e3a) : _0x5c8e3a;
        }

        // Push node permissions to the permissions array
        sig._0xf89bbb[_0xe60c88++] = _0x01c783;
        continue;
      }

      // Node (0x01)
      if (_0xd459b6 == FLAG_NODE) {
        // Read pre-hashed node
        bytes32 _0xb46c52;
        (_0xb46c52, _0xab975a) = _0xbe38c1._0x6510bc(_0xab975a);

        // Update root
        sig._0xb7c8bb = sig._0xb7c8bb != bytes32(0) ? LibOptim._0x886f6e(sig._0xb7c8bb, _0xb46c52) : _0xb46c52;

        continue;
      }

      // Branch (0x02)
      if (_0xd459b6 == FLAG_BRANCH) {
        // Read branch size
        uint256 _0xe42aa5;
        {
          uint256 _0x958cda = uint8(_0x69780e & 0x0f);
          (_0xe42aa5, _0xab975a) = _0xbe38c1._0xf11472(_0xab975a, _0x958cda);
        }
        // Process branch
        uint256 _0xe86d3d = _0xab975a + _0xe42aa5;
        (DecodedSignature memory _0x06cc7f, bool _0x6a52f6) = _0x651164(_0xbe38c1[_0xab975a:_0xe86d3d]);
        _0xab975a = _0xe86d3d;

        // Store the branch blacklist
        if (_0x6a52f6) {
          if (_0xa87132) {
            // Blacklist already set
            revert SessionErrors.InvalidBlacklist();
          }
          _0xa87132 = true;
          sig._0xc094fb = _0x06cc7f._0xc094fb;
        }

        // Store the branch identity signer
        if (_0x06cc7f._0xdb8ad9 != address(0)) {
          if (sig._0xdb8ad9 != address(0)) {
            // Identity signer already set
            revert SessionErrors.InvalidIdentitySigner();
          }
          sig._0xdb8ad9 = _0x06cc7f._0xdb8ad9;
        }

        // Push all branch permissions to the permissions array
        for (uint256 i = 0; i < _0x06cc7f._0xf89bbb.length; i++) {
          sig._0xf89bbb[_0xe60c88++] = _0x06cc7f._0xf89bbb[i];
        }

        // Update root
        sig._0xb7c8bb =
          sig._0xb7c8bb != bytes32(0) ? LibOptim._0x886f6e(sig._0xb7c8bb, _0x06cc7f._0xb7c8bb) : _0x06cc7f._0xb7c8bb;

        continue;
      }

      // Blacklist (0x03)
      if (_0xd459b6 == FLAG_BLACKLIST) {
        if (_0xa87132) {
          // Blacklist already set
          revert SessionErrors.InvalidBlacklist();
        }
        _0xa87132 = true;

        // Read the blacklist count from the first byte's lower 4 bits
        uint256 _0xbf76be = uint256(_0x69780e & 0x0f);
        if (_0xbf76be == 0x0f) {
          // If it's max nibble, read the next 2 bytes for the actual size
          (_0xbf76be, _0xab975a) = _0xbe38c1._0xdedaf7(_0xab975a);
        }
        uint256 _0xd27d12 = _0xab975a;

        // Read the blacklist addresses
        sig._0xc094fb = new address[](_0xbf76be);
        address _0x9a9dcc;
        for (uint256 i = 0; i < _0xbf76be; i++) {
          (sig._0xc094fb[i], _0xab975a) = _0xbe38c1._0xa53622(_0xab975a);
          if (sig._0xc094fb[i] < _0x9a9dcc) {
            revert SessionErrors.InvalidBlacklistUnsorted();
          }
          _0x9a9dcc = sig._0xc094fb[i];
        }

        // Update the root
        bytes32 _0x514953 = _0x424e6c(_0xbe38c1[_0xd27d12:_0xab975a]);
        sig._0xb7c8bb = sig._0xb7c8bb != bytes32(0) ? LibOptim._0x886f6e(sig._0xb7c8bb, _0x514953) : _0x514953;

        continue;
      }

      // Identity signer (0x04)
      if (_0xd459b6 == FLAG_IDENTITY_SIGNER) {
        if (sig._0xdb8ad9 != address(0)) {
          // Identity signer already set
          revert SessionErrors.InvalidIdentitySigner();
        }
        (sig._0xdb8ad9, _0xab975a) = _0xbe38c1._0xa53622(_0xab975a);

        // Update the root
        bytes32 _0xf442f7 = _0x168b5e(sig._0xdb8ad9);
        sig._0xb7c8bb =
          sig._0xb7c8bb != bytes32(0) ? LibOptim._0x886f6e(sig._0xb7c8bb, _0xf442f7) : _0xf442f7;

        continue;
      }

      revert SessionErrors.InvalidNodeType(_0xd459b6);
    }

    {
      // Update the permissions array length to the actual count
      SessionPermissions[] memory _0xb18c32 = sig._0xf89bbb;
      assembly {
        mstore(_0xb18c32, _0xe60c88)
      }
    }

    return (sig, _0xa87132);
  }

  /// @notice Decodes an array of Permission objects from the encoded data.
  function _0x828429(
    bytes calldata _0xbe38c1,
    uint256 _0xab975a
  ) internal pure returns (Permission[] memory _0xb18c32, uint256 _0xa8be81) {
    uint256 length;
    (length, _0xab975a) = _0xbe38c1._0xa746c1(_0xab975a);
    _0xb18c32 = new Permission[](length);
    for (uint256 i = 0; i < length; i++) {
      (_0xb18c32[i], _0xab975a) = LibPermission._0x37f7b3(_0xbe38c1, _0xab975a);
    }
    return (_0xb18c32, _0xab975a);
  }

  /// @notice Hashes the encoded session permissions into a leaf node.
  function _0xb289fb(
    bytes calldata _0xa96108
  ) internal pure returns (bytes32) {
    return _0x0e3955(abi._0xdd3325(uint8(FLAG_PERMISSIONS), _0xa96108));
  }

  /// @notice Hashes the encoded blacklist into a leaf node.
  function _0x424e6c(
    bytes calldata _0x817b01
  ) internal pure returns (bytes32) {
    return _0x0e3955(abi._0xdd3325(uint8(FLAG_BLACKLIST), _0x817b01));
  }

  /// @notice Hashes the identity signer into a leaf node.
  function _0x168b5e(
    address _0xdb8ad9
  ) internal pure returns (bytes32) {
    return _0x0e3955(abi._0xdd3325(uint8(FLAG_IDENTITY_SIGNER), _0xdb8ad9));
  }

  /// @notice Hashes a call with replay protection.
  /// @dev The replay protection is based on the chainId, space, nonce and index in the payload.
  /// @param payload The payload to hash
  /// @param callIdx The index of the call to hash
  /// @return callHash The hash of the call with replay protection
  function _0x761864(
    Payload.Decoded calldata _0xc6fccb,
    uint256 _0x47af8c
  ) public view returns (bytes32 _0x0cd720) {
    return _0x0e3955(
      abi._0xdd3325(
        _0xc6fccb._0x74ce5c ? 0 : block.chainid,
        _0xc6fccb._0x1d2d0f,
        _0xc6fccb._0x4ced68,
        _0x47af8c,
        Payload._0x1617fa(_0xc6fccb._0xe2eee6[_0x47af8c])
      )
    );
  }

}

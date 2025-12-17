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
    bool _0xe9718e;
    address _0xdf20aa;
    uint8 _0xbb10af;
    Attestation _0xb1efa3;
  }

  /// @notice Decoded signature for a specific session
  /// @param imageHash Derived configuration image hash
  /// @param identitySigner Identity signer address
  /// @param implicitBlacklist Implicit blacklist addresses
  /// @param sessionPermissions Session permissions for each explicit signer
  /// @param callSignatures Call signatures for each call in the payload
  struct DecodedSignature {
    bytes32 _0x358049;
    address _0xf7c0aa;
    address[] _0x2aca70;
    SessionPermissions[] _0xfb5d3a;
    CallSignature[] _0x07d268;
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
  function _0x530e11(
    Payload.Decoded calldata _0x162372,
    bytes calldata _0x468958
  ) internal view returns (DecodedSignature memory sig) {
    uint256 _0xd2b6ba = 0;
    bool _0xdbb70e;

    // ----- Session Configuration -----
    {
      // First read the length of the session configuration bytes (uint24)
      uint256 _0x036f5d;
      (_0x036f5d, _0xd2b6ba) = _0x468958._0x4aca2e(_0xd2b6ba);

      // Recover the session configuration
      (sig, _0xdbb70e) = _0x276e2b(_0x468958[_0xd2b6ba:_0xd2b6ba + _0x036f5d]);
      _0xd2b6ba += _0x036f5d;

      // Identity signer must be set
      if (sig._0xf7c0aa == address(0)) {
        revert SessionErrors.InvalidIdentitySigner();
      }
    }

    // ----- Attestations for implicit calls -----
    Attestation[] memory _0x81d593;
    {
      uint8 _0xce7857;
      (_0xce7857, _0xd2b6ba) = _0x468958._0x98871d(_0xd2b6ba);
      _0x81d593 = new Attestation[](_0xce7857);
      // Parse each attestation and its identity signature, store in memory
      for (uint256 i = 0; i < _0xce7857; i++) {
        Attestation memory _0xf412fd;
        (_0xf412fd, _0xd2b6ba) = LibAttestation._0x345082(_0x468958, _0xd2b6ba);

        // Read the identity signature that approves this attestation
        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xd2b6ba) = _0x468958._0x87d3a9(_0xd2b6ba);

          // Recover the identity signer from the attestation identity signature
          bytes32 _0xd1483f = _0xf412fd._0x1721ae();
          address _0xdb561d = _0x6745c0(_0xd1483f, v, r, s);
          if (_0xdb561d != sig._0xf7c0aa) {
            revert SessionErrors.InvalidIdentitySigner();
          }
        }

        _0x81d593[i] = _0xf412fd;
      }

      // If we have any implicit calls, we must have a blacklist in the configuration
      if (_0xce7857 > 0 && !_0xdbb70e) {
        revert SessionErrors.InvalidBlacklist();
      }
    }

    // ----- Call Signatures -----
    {
      uint256 _0x219454 = _0x162372._0x79f12d.length;
      sig._0x07d268 = new CallSignature[](_0x219454);

      for (uint256 i = 0; i < _0x219454; i++) {
        CallSignature memory _0x5b3c1e;

        // Determine signature type
        {
          uint8 _0x930e19;
          (_0x930e19, _0xd2b6ba) = _0x468958._0x98871d(_0xd2b6ba);
          _0x5b3c1e._0xe9718e = (_0x930e19 & 0x80) != 0;

          if (_0x5b3c1e._0xe9718e) {
            // Read attestation index from the call_flags
            uint8 _0x77129c = uint8(_0x930e19 & 0x7f);

            // Check if the attestation index is out of range
            if (_0x77129c >= _0x81d593.length) {
              revert SessionErrors.InvalidAttestation();
            }

            // Set the attestation
            _0x5b3c1e._0xb1efa3 = _0x81d593[_0x77129c];
          } else {
            // Session permission index is the entire byte, top bit is 0 => no conflict
            _0x5b3c1e._0xbb10af = _0x930e19;
          }
        }

        // Read session signature and recover the signer
        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xd2b6ba) = _0x468958._0x87d3a9(_0xd2b6ba);

          bytes32 _0xb5b66e = _0x6cd6f3(_0x162372, i);
          _0x5b3c1e._0xdf20aa = _0x6745c0(_0xb5b66e, v, r, s);
          if (_0x5b3c1e._0xdf20aa == address(0)) {
            revert SessionErrors.InvalidSessionSigner(address(0));
          }
        }

        sig._0x07d268[i] = _0x5b3c1e;
      }
    }

    return sig;
  }

  /// @notice Recovers the session configuration from the encoded data.
  function _0x276e2b(
    bytes calldata _0x642c18
  ) internal pure returns (DecodedSignature memory sig, bool _0x9aab11) {
    uint256 _0xd2b6ba;
    uint256 _0x20de72;

    // Guess maximum permissions size by bytes length
    {
      uint256 _0xa8ba30 = _0x642c18.length / MIN_ENCODED_PERMISSION_SIZE;
      sig._0xfb5d3a = new SessionPermissions[](_0xa8ba30);
    }

    while (_0xd2b6ba < _0x642c18.length) {
      // First byte is the flag (top 4 bits) and additional data (bottom 4 bits)
      uint256 _0x838072;
      (_0x838072, _0xd2b6ba) = _0x642c18._0x98871d(_0xd2b6ba);
      // The top 4 bits are the flag
      uint256 _0x930e19 = (_0x838072 & 0xf0) >> 4;

      // Permissions configuration (0x00)
      if (_0x930e19 == FLAG_PERMISSIONS) {
        SessionPermissions memory _0xcf0437;
        uint256 _0x62a22f = _0xd2b6ba;

        // Read signer
        (_0xcf0437._0x63cba6, _0xd2b6ba) = _0x642c18._0x57c9a6(_0xd2b6ba);

        // Read chainId
        (_0xcf0437.chainId, _0xd2b6ba) = _0x642c18._0xe639f9(_0xd2b6ba);

        // Read value limit
        (_0xcf0437._0xd73033, _0xd2b6ba) = _0x642c18._0xe639f9(_0xd2b6ba);

        // Read deadline
        (_0xcf0437._0x10b854, _0xd2b6ba) = _0x642c18._0x35c7fc(_0xd2b6ba);

        // Read permissions array
        (_0xcf0437._0x2942fa, _0xd2b6ba) = _0xe99510(_0x642c18, _0xd2b6ba);

        // Update root
        {
          bytes32 _0x2c4551 = _0xcaaf92(_0x642c18[_0x62a22f:_0xd2b6ba]);
          sig._0x358049 =
            sig._0x358049 != bytes32(0) ? LibOptim._0x5e172b(sig._0x358049, _0x2c4551) : _0x2c4551;
        }

        // Push node permissions to the permissions array
        sig._0xfb5d3a[_0x20de72++] = _0xcf0437;
        continue;
      }

      // Node (0x01)
      if (_0x930e19 == FLAG_NODE) {
        // Read pre-hashed node
        bytes32 _0x038c15;
        (_0x038c15, _0xd2b6ba) = _0x642c18._0x8cf806(_0xd2b6ba);

        // Update root
        sig._0x358049 = sig._0x358049 != bytes32(0) ? LibOptim._0x5e172b(sig._0x358049, _0x038c15) : _0x038c15;

        continue;
      }

      // Branch (0x02)
      if (_0x930e19 == FLAG_BRANCH) {
        // Read branch size
        uint256 _0xcaffd7;
        {
          uint256 _0xe5baf4 = uint8(_0x838072 & 0x0f);
          (_0xcaffd7, _0xd2b6ba) = _0x642c18._0xeae744(_0xd2b6ba, _0xe5baf4);
        }
        // Process branch
        uint256 _0x0390eb = _0xd2b6ba + _0xcaffd7;
        (DecodedSignature memory _0x147a0d, bool _0x621e56) = _0x276e2b(_0x642c18[_0xd2b6ba:_0x0390eb]);
        _0xd2b6ba = _0x0390eb;

        // Store the branch blacklist
        if (_0x621e56) {
          if (_0x9aab11) {
            // Blacklist already set
            revert SessionErrors.InvalidBlacklist();
          }
          _0x9aab11 = true;
          sig._0x2aca70 = _0x147a0d._0x2aca70;
        }

        // Store the branch identity signer
        if (_0x147a0d._0xf7c0aa != address(0)) {
          if (sig._0xf7c0aa != address(0)) {
            // Identity signer already set
            revert SessionErrors.InvalidIdentitySigner();
          }
          sig._0xf7c0aa = _0x147a0d._0xf7c0aa;
        }

        // Push all branch permissions to the permissions array
        for (uint256 i = 0; i < _0x147a0d._0xfb5d3a.length; i++) {
          sig._0xfb5d3a[_0x20de72++] = _0x147a0d._0xfb5d3a[i];
        }

        // Update root
        sig._0x358049 =
          sig._0x358049 != bytes32(0) ? LibOptim._0x5e172b(sig._0x358049, _0x147a0d._0x358049) : _0x147a0d._0x358049;

        continue;
      }

      // Blacklist (0x03)
      if (_0x930e19 == FLAG_BLACKLIST) {
        if (_0x9aab11) {
          // Blacklist already set
          revert SessionErrors.InvalidBlacklist();
        }
        _0x9aab11 = true;

        // Read the blacklist count from the first byte's lower 4 bits
        uint256 _0xe85ac5 = uint256(_0x838072 & 0x0f);
        if (_0xe85ac5 == 0x0f) {
          // If it's max nibble, read the next 2 bytes for the actual size
          (_0xe85ac5, _0xd2b6ba) = _0x642c18._0xa22c1a(_0xd2b6ba);
        }
        uint256 _0x62a22f = _0xd2b6ba;

        // Read the blacklist addresses
        sig._0x2aca70 = new address[](_0xe85ac5);
        address _0xf3abbc;
        for (uint256 i = 0; i < _0xe85ac5; i++) {
          (sig._0x2aca70[i], _0xd2b6ba) = _0x642c18._0x57c9a6(_0xd2b6ba);
          if (sig._0x2aca70[i] < _0xf3abbc) {
            revert SessionErrors.InvalidBlacklistUnsorted();
          }
          _0xf3abbc = sig._0x2aca70[i];
        }

        // Update the root
        bytes32 _0x264e96 = _0xe305bb(_0x642c18[_0x62a22f:_0xd2b6ba]);
        sig._0x358049 = sig._0x358049 != bytes32(0) ? LibOptim._0x5e172b(sig._0x358049, _0x264e96) : _0x264e96;

        continue;
      }

      // Identity signer (0x04)
      if (_0x930e19 == FLAG_IDENTITY_SIGNER) {
        if (sig._0xf7c0aa != address(0)) {
          // Identity signer already set
          revert SessionErrors.InvalidIdentitySigner();
        }
        (sig._0xf7c0aa, _0xd2b6ba) = _0x642c18._0x57c9a6(_0xd2b6ba);

        // Update the root
        bytes32 _0x19ff48 = _0x096c2d(sig._0xf7c0aa);
        sig._0x358049 =
          sig._0x358049 != bytes32(0) ? LibOptim._0x5e172b(sig._0x358049, _0x19ff48) : _0x19ff48;

        continue;
      }

      revert SessionErrors.InvalidNodeType(_0x930e19);
    }

    {
      // Update the permissions array length to the actual count
      SessionPermissions[] memory _0x2942fa = sig._0xfb5d3a;
      assembly {
        mstore(_0x2942fa, _0x20de72)
      }
    }

    return (sig, _0x9aab11);
  }

  /// @notice Decodes an array of Permission objects from the encoded data.
  function _0xe99510(
    bytes calldata _0x642c18,
    uint256 _0xd2b6ba
  ) internal pure returns (Permission[] memory _0x2942fa, uint256 _0xa2c091) {
    uint256 length;
    (length, _0xd2b6ba) = _0x642c18._0x98871d(_0xd2b6ba);
    _0x2942fa = new Permission[](length);
    for (uint256 i = 0; i < length; i++) {
      (_0x2942fa[i], _0xd2b6ba) = LibPermission._0x4cb0a7(_0x642c18, _0xd2b6ba);
    }
    return (_0x2942fa, _0xd2b6ba);
  }

  /// @notice Hashes the encoded session permissions into a leaf node.
  function _0xcaaf92(
    bytes calldata _0xde0ca8
  ) internal pure returns (bytes32) {
    return _0x851f94(abi._0x8483e8(uint8(FLAG_PERMISSIONS), _0xde0ca8));
  }

  /// @notice Hashes the encoded blacklist into a leaf node.
  function _0xe305bb(
    bytes calldata _0x78bef4
  ) internal pure returns (bytes32) {
    return _0x851f94(abi._0x8483e8(uint8(FLAG_BLACKLIST), _0x78bef4));
  }

  /// @notice Hashes the identity signer into a leaf node.
  function _0x096c2d(
    address _0xf7c0aa
  ) internal pure returns (bytes32) {
    return _0x851f94(abi._0x8483e8(uint8(FLAG_IDENTITY_SIGNER), _0xf7c0aa));
  }

  /// @notice Hashes a call with replay protection.
  /// @dev The replay protection is based on the chainId, space, nonce and index in the payload.
  /// @param payload The payload to hash
  /// @param callIdx The index of the call to hash
  /// @return callHash The hash of the call with replay protection
  function _0x6cd6f3(
    Payload.Decoded calldata _0x162372,
    uint256 _0xa6eaf1
  ) public view returns (bytes32 _0xb5b66e) {
    return _0x851f94(
      abi._0x8483e8(
        _0x162372._0xfe1660 ? 0 : block.chainid,
        _0x162372._0x17913d,
        _0x162372._0xddc693,
        _0xa6eaf1,
        Payload._0x05a619(_0x162372._0x79f12d[_0xa6eaf1])
      )
    );
  }

}

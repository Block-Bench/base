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
    bool ar;
    address ag;
    uint8 o;
    Attestation al;
  }

  /// @notice Decoded signature for a specific session
  /// @param imageHash Derived configuration image hash
  /// @param identitySigner Identity signer address
  /// @param implicitBlacklist Implicit blacklist addresses
  /// @param sessionPermissions Session permissions for each explicit signer
  /// @param callSignatures Call signatures for each call in the payload
  struct DecodedSignature {
    bytes32 bf;
    address z;
    address[] n;
    SessionPermissions[] m;
    CallSignature[] ae;
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
  function s(
    Payload.Decoded calldata bm,
    bytes calldata p
  ) internal view returns (DecodedSignature memory sig) {
    uint256 bn = 0;
    bool f;

    // ----- Session Configuration -----
    {
      // First read the length of the session configuration bytes (uint24)
      uint256 bk;
      (bk, bn) = p.aq(bn);

      // Recover the session configuration
      (sig, f) = g(p[bn:bn + bk]);
      bn += bk;

      // Identity signer must be set
      if (sig.z == address(0)) {
        revert SessionErrors.InvalidIdentitySigner();
      }
    }

    // ----- Attestations for implicit calls -----
    Attestation[] memory v;
    {
      uint8 r;
      (r, bn) = p.ba(bn);
      v = new Attestation[](r);
      // Parse each attestation and its identity signature, store in memory
      for (uint256 i = 0; i < r; i++) {
        Attestation memory bz;
        (bz, bn) = LibAttestation.aw(p, bn);

        // Read the identity signature that approves this attestation
        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, bn) = p.aa(bn);

          // Recover the identity signer from the attestation identity signature
          bytes32 x = bz.bs();
          address c = bc(x, v, r, s);
          if (c != sig.z) {
            revert SessionErrors.InvalidIdentitySigner();
          }
        }

        v[i] = bz;
      }

      // If we have any implicit calls, we must have a blacklist in the configuration
      if (r > 0 && !f) {
        revert SessionErrors.InvalidBlacklist();
      }
    }

    // ----- Call Signatures -----
    {
      uint256 ay = bm.bv.length;
      sig.ae = new CallSignature[](ay);

      for (uint256 i = 0; i < ay; i++) {
        CallSignature memory af;

        // Determine signature type
        {
          uint8 bw;
          (bw, bn) = p.ba(bn);
          af.ar = (bw & 0x80) != 0;

          if (af.ar) {
            // Read attestation index from the call_flags
            uint8 q = uint8(bw & 0x7f);

            // Check if the attestation index is out of range
            if (q >= v.length) {
              revert SessionErrors.InvalidAttestation();
            }

            // Set the attestation
            af.al = v[q];
          } else {
            // Session permission index is the entire byte, top bit is 0 => no conflict
            af.o = bw;
          }
        }

        // Read session signature and recover the signer
        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, bn) = p.aa(bn);

          bytes32 bi = a(bm, i);
          af.ag = bc(bi, v, r, s);
          if (af.ag == address(0)) {
            revert SessionErrors.InvalidSessionSigner(address(0));
          }
        }

        sig.ae[i] = af;
      }
    }

    return sig;
  }

  /// @notice Recovers the session configuration from the encoded data.
  function g(
    bytes calldata bq
  ) internal pure returns (DecodedSignature memory sig, bool ak) {
    uint256 bn;
    uint256 t;

    // Guess maximum permissions size by bytes length
    {
      uint256 l = bq.length / MIN_ENCODED_PERMISSION_SIZE;
      sig.m = new SessionPermissions[](l);
    }

    while (bn < bq.length) {
      // First byte is the flag (top 4 bits) and additional data (bottom 4 bits)
      uint256 bg;
      (bg, bn) = bq.ba(bn);
      // The top 4 bits are the flag
      uint256 bw = (bg & 0xf0) >> 4;

      // Permissions configuration (0x00)
      if (bw == FLAG_PERMISSIONS) {
        SessionPermissions memory w;
        uint256 aj = bn;

        // Read signer
        (w.br, bn) = bq.an(bn);

        // Read chainId
        (w.chainId, bn) = bq.ao(bn);

        // Read value limit
        (w.au, bn) = bq.ao(bn);

        // Read deadline
        (w.bj, bn) = bq.at(bn);

        // Read permissions array
        (w.ap, bn) = k(bq, bn);

        // Update root
        {
          bytes32 ab = d(bq[aj:bn]);
          sig.bf =
            sig.bf != bytes32(0) ? LibOptim.as(sig.bf, ab) : ab;
        }

        // Push node permissions to the permissions array
        sig.m[t++] = w;
        continue;
      }

      // Node (0x01)
      if (bw == FLAG_NODE) {
        // Read pre-hashed node
        bytes32 by;
        (by, bn) = bq.am(bn);

        // Update root
        sig.bf = sig.bf != bytes32(0) ? LibOptim.as(sig.bf, by) : by;

        continue;
      }

      // Branch (0x02)
      if (bw == FLAG_BRANCH) {
        // Read branch size
        uint256 bx;
        {
          uint256 bh = uint8(bg & 0x0f);
          (bx, bn) = bq.az(bn, bh);
        }
        // Process branch
        uint256 bp = bn + bx;
        (DecodedSignature memory bd, bool h) = g(bq[bn:bp]);
        bn = bp;

        // Store the branch blacklist
        if (h) {
          if (ak) {
            // Blacklist already set
            revert SessionErrors.InvalidBlacklist();
          }
          ak = true;
          sig.n = bd.n;
        }

        // Store the branch identity signer
        if (bd.z != address(0)) {
          if (sig.z != address(0)) {
            // Identity signer already set
            revert SessionErrors.InvalidIdentitySigner();
          }
          sig.z = bd.z;
        }

        // Push all branch permissions to the permissions array
        for (uint256 i = 0; i < bd.m.length; i++) {
          sig.m[t++] = bd.m[i];
        }

        // Update root
        sig.bf =
          sig.bf != bytes32(0) ? LibOptim.as(sig.bf, bd.bf) : bd.bf;

        continue;
      }

      // Blacklist (0x03)
      if (bw == FLAG_BLACKLIST) {
        if (ak) {
          // Blacklist already set
          revert SessionErrors.InvalidBlacklist();
        }
        ak = true;

        // Read the blacklist count from the first byte's lower 4 bits
        uint256 ac = uint256(bg & 0x0f);
        if (ac == 0x0f) {
          // If it's max nibble, read the next 2 bytes for the actual size
          (ac, bn) = bq.av(bn);
        }
        uint256 aj = bn;

        // Read the blacklist addresses
        sig.n = new address[](ac);
        address y;
        for (uint256 i = 0; i < ac; i++) {
          (sig.n[i], bn) = bq.an(bn);
          if (sig.n[i] < y) {
            revert SessionErrors.InvalidBlacklistUnsorted();
          }
          y = sig.n[i];
        }

        // Update the root
        bytes32 ah = e(bq[aj:bn]);
        sig.bf = sig.bf != bytes32(0) ? LibOptim.as(sig.bf, ah) : ah;

        continue;
      }

      // Identity signer (0x04)
      if (bw == FLAG_IDENTITY_SIGNER) {
        if (sig.z != address(0)) {
          // Identity signer already set
          revert SessionErrors.InvalidIdentitySigner();
        }
        (sig.z, bn) = bq.an(bn);

        // Update the root
        bytes32 i = b(sig.z);
        sig.bf =
          sig.bf != bytes32(0) ? LibOptim.as(sig.bf, i) : i;

        continue;
      }

      revert SessionErrors.InvalidNodeType(bw);
    }

    {
      // Update the permissions array length to the actual count
      SessionPermissions[] memory ap = sig.m;
      assembly {
        mstore(ap, t)
      }
    }

    return (sig, ak);
  }

  /// @notice Decodes an array of Permission objects from the encoded data.
  function k(
    bytes calldata bq,
    uint256 bn
  ) internal pure returns (Permission[] memory ap, uint256 ax) {
    uint256 length;
    (length, bn) = bq.ba(bn);
    ap = new Permission[](length);
    for (uint256 i = 0; i < length; i++) {
      (ap[i], bn) = LibPermission.ad(bq, bn);
    }
    return (ap, bn);
  }

  /// @notice Hashes the encoded session permissions into a leaf node.
  function d(
    bytes calldata j
  ) internal pure returns (bytes32) {
    return bb(abi.ai(uint8(FLAG_PERMISSIONS), j));
  }

  /// @notice Hashes the encoded blacklist into a leaf node.
  function e(
    bytes calldata u
  ) internal pure returns (bytes32) {
    return bb(abi.ai(uint8(FLAG_BLACKLIST), u));
  }

  /// @notice Hashes the identity signer into a leaf node.
  function b(
    address z
  ) internal pure returns (bytes32) {
    return bb(abi.ai(uint8(FLAG_IDENTITY_SIGNER), z));
  }

  /// @notice Hashes a call with replay protection.
  /// @dev The replay protection is based on the chainId, space, nonce and index in the payload.
  /// @param payload The payload to hash
  /// @param callIdx The index of the call to hash
  /// @return callHash The hash of the call with replay protection
  function a(
    Payload.Decoded calldata bm,
    uint256 bo
  ) public view returns (bytes32 bi) {
    return bb(
      abi.ai(
        bm.be ? 0 : block.chainid,
        bm.bu,
        bm.bt,
        bo,
        Payload.bl(bm.bv[bo])
      )
    );
  }

}

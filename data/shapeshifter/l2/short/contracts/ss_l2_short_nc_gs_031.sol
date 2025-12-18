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


library SessionSig {

  uint256 internal constant FLAG_PERMISSIONS = 0;
  uint256 internal constant FLAG_NODE = 1;
  uint256 internal constant FLAG_BRANCH = 2;
  uint256 internal constant FLAG_BLACKLIST = 3;
  uint256 internal constant FLAG_IDENTITY_SIGNER = 4;

  uint256 internal constant MIN_ENCODED_PERMISSION_SIZE = 94;


  struct CallSignature {
    bool au;
    address ah;
    uint8 o;
    Attestation ao;
  }


  struct DecodedSignature {
    bytes32 bg;
    address z;
    address[] n;
    SessionPermissions[] i;
    CallSignature[] ac;
  }


  function p(
    Payload.Decoded calldata bo,
    bytes calldata u
  ) internal view returns (DecodedSignature memory sig) {
    uint256 bn = 0;
    bool f;


    {

      uint256 bl;
      (bl, bn) = u.at(bn);


      (sig, f) = g(u[bn:bn + bl]);
      bn += bl;


      if (sig.z == address(0)) {
        revert SessionErrors.InvalidIdentitySigner();
      }
    }


    Attestation[] memory x;
    {
      uint8 s;
      (s, bn) = u.bd(bn);
      x = new Attestation[](s);

      for (uint256 i = 0; i < s; i++) {
        Attestation memory bz;
        (bz, bn) = LibAttestation.aw(u, bn);


        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, bn) = u.aa(bn);


          bytes32 v = bz.br();
          address c = be(v, v, r, s);
          if (c != sig.z) {
            revert SessionErrors.InvalidIdentitySigner();
          }
        }

        x[i] = bz;
      }


      if (s > 0 && !f) {
        revert SessionErrors.InvalidBlacklist();
      }
    }


    {
      uint256 ay = bo.bt.length;
      sig.ac = new CallSignature[](ay);

      for (uint256 i = 0; i < ay; i++) {
        CallSignature memory af;


        {
          uint8 bw;
          (bw, bn) = u.bd(bn);
          af.au = (bw & 0x80) != 0;

          if (af.au) {

            uint8 t = uint8(bw & 0x7f);


            if (t >= x.length) {
              revert SessionErrors.InvalidAttestation();
            }


            af.ao = x[t];
          } else {

            af.o = bw;
          }
        }


        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, bn) = u.aa(bn);

          bytes32 bi = a(bo, i);
          af.ah = be(bi, v, r, s);
          if (af.ah == address(0)) {
            revert SessionErrors.InvalidSessionSigner(address(0));
          }
        }

        sig.ac[i] = af;
      }
    }

    return sig;
  }


  function g(
    bytes calldata bq
  ) internal pure returns (DecodedSignature memory sig, bool aj) {
    uint256 bn;
    uint256 r;


    {
      uint256 j = bq.length / MIN_ENCODED_PERMISSION_SIZE;
      sig.i = new SessionPermissions[](j);
    }

    while (bn < bq.length) {

      uint256 az;
      (az, bn) = bq.bd(bn);

      uint256 bw = (az & 0xf0) >> 4;


      if (bw == FLAG_PERMISSIONS) {
        SessionPermissions memory w;
        uint256 ak = bn;


        (w.bs, bn) = bq.al(bn);


        (w.chainId, bn) = bq.an(bn);


        (w.aq, bn) = bq.an(bn);


        (w.bk, bn) = bq.ax(bn);


        (w.ap, bn) = m(bq, bn);


        {
          bytes32 ae = d(bq[ak:bn]);
          sig.bg =
            sig.bg != bytes32(0) ? LibOptim.as(sig.bg, ae) : ae;
        }


        sig.i[r++] = w;
        continue;
      }


      if (bw == FLAG_NODE) {

        bytes32 bx;
        (bx, bn) = bq.am(bn);


        sig.bg = sig.bg != bytes32(0) ? LibOptim.as(sig.bg, bx) : bx;

        continue;
      }


      if (bw == FLAG_BRANCH) {

        uint256 by;
        {
          uint256 bh = uint8(az & 0x0f);
          (by, bn) = bq.bf(bn, bh);
        }

        uint256 bp = bn + by;
        (DecodedSignature memory bb, bool l) = g(bq[bn:bp]);
        bn = bp;


        if (l) {
          if (aj) {

            revert SessionErrors.InvalidBlacklist();
          }
          aj = true;
          sig.n = bb.n;
        }


        if (bb.z != address(0)) {
          if (sig.z != address(0)) {

            revert SessionErrors.InvalidIdentitySigner();
          }
          sig.z = bb.z;
        }


        for (uint256 i = 0; i < bb.i.length; i++) {
          sig.i[r++] = bb.i[i];
        }


        sig.bg =
          sig.bg != bytes32(0) ? LibOptim.as(sig.bg, bb.bg) : bb.bg;

        continue;
      }


      if (bw == FLAG_BLACKLIST) {
        if (aj) {

          revert SessionErrors.InvalidBlacklist();
        }
        aj = true;


        uint256 ad = uint256(az & 0x0f);
        if (ad == 0x0f) {

          (ad, bn) = bq.ar(bn);
        }
        uint256 ak = bn;


        sig.n = new address[](ad);
        address y;
        for (uint256 i = 0; i < ad; i++) {
          (sig.n[i], bn) = bq.al(bn);
          if (sig.n[i] < y) {
            revert SessionErrors.InvalidBlacklistUnsorted();
          }
          y = sig.n[i];
        }


        bytes32 ag = e(bq[ak:bn]);
        sig.bg = sig.bg != bytes32(0) ? LibOptim.as(sig.bg, ag) : ag;

        continue;
      }


      if (bw == FLAG_IDENTITY_SIGNER) {
        if (sig.z != address(0)) {

          revert SessionErrors.InvalidIdentitySigner();
        }
        (sig.z, bn) = bq.al(bn);


        bytes32 k = b(sig.z);
        sig.bg =
          sig.bg != bytes32(0) ? LibOptim.as(sig.bg, k) : k;

        continue;
      }

      revert SessionErrors.InvalidNodeType(bw);
    }

    {

      SessionPermissions[] memory ap = sig.i;
      assembly {
        mstore(ap, r)
      }
    }

    return (sig, aj);
  }


  function m(
    bytes calldata bq,
    uint256 bn
  ) internal pure returns (Permission[] memory ap, uint256 av) {
    uint256 length;
    (length, bn) = bq.bd(bn);
    ap = new Permission[](length);
    for (uint256 i = 0; i < length; i++) {
      (ap[i], bn) = LibPermission.ab(bq, bn);
    }
    return (ap, bn);
  }


  function d(
    bytes calldata h
  ) internal pure returns (bytes32) {
    return ba(abi.ai(uint8(FLAG_PERMISSIONS), h));
  }


  function e(
    bytes calldata q
  ) internal pure returns (bytes32) {
    return ba(abi.ai(uint8(FLAG_BLACKLIST), q));
  }


  function b(
    address z
  ) internal pure returns (bytes32) {
    return ba(abi.ai(uint8(FLAG_IDENTITY_SIGNER), z));
  }


  function a(
    Payload.Decoded calldata bo,
    uint256 bm
  ) public view returns (bytes32 bi) {
    return ba(
      abi.ai(
        bo.bc ? 0 : block.chainid,
        bo.bv,
        bo.bu,
        bm,
        Payload.bj(bo.bt[bm])
      )
    );
  }

}
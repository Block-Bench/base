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
    bool av;
    address ah;
    uint8 o;
    Attestation ap;
  }


  struct DecodedSignature {
    bytes32 bc;
    address ad;
    address[] n;
    SessionPermissions[] m;
    CallSignature[] ac;
  }


  function p(
    Payload.Decoded calldata bq,
    bytes calldata r
  ) internal view returns (DecodedSignature memory sig) {
    uint256 bo = 0;
    bool g;


    {

      uint256 bj;
      (bj, bo) = r.au(bo);


      (sig, g) = f(r[bo:bo + bj]);
      bo += bj;


      if (sig.ad == address(0)) {
        revert SessionErrors.InvalidIdentitySigner();
      }
    }


    Attestation[] memory v;
    {
      uint8 q;
      (q, bo) = r.bg(bo);
      v = new Attestation[](q);

      for (uint256 i = 0; i < q; i++) {
        Attestation memory bz;
        (bz, bo) = LibAttestation.aq(r, bo);


        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, bo) = r.z(bo);


          bytes32 y = bz.br();
          address d = az(y, v, r, s);
          if (d != sig.ad) {
            revert SessionErrors.InvalidIdentitySigner();
          }
        }

        v[i] = bz;
      }


      if (q > 0 && !g) {
        revert SessionErrors.InvalidBlacklist();
      }
    }


    {
      uint256 aw = bq.bu.length;
      sig.ac = new CallSignature[](aw);

      for (uint256 i = 0; i < aw; i++) {
        CallSignature memory ag;


        {
          uint8 bx;
          (bx, bo) = r.bg(bo);
          ag.av = (bx & 0x80) != 0;

          if (ag.av) {

            uint8 s = uint8(bx & 0x7f);


            if (s >= v.length) {
              revert SessionErrors.InvalidAttestation();
            }


            ag.ap = v[s];
          } else {

            ag.o = bx;
          }
        }


        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, bo) = r.z(bo);

          bytes32 bk = a(bq, i);
          ag.ah = az(bk, v, r, s);
          if (ag.ah == address(0)) {
            revert SessionErrors.InvalidSessionSigner(address(0));
          }
        }

        sig.ac[i] = ag;
      }
    }

    return sig;
  }


  function f(
    bytes calldata bn
  ) internal pure returns (DecodedSignature memory sig, bool ai) {
    uint256 bo;
    uint256 u;


    {
      uint256 j = bn.length / MIN_ENCODED_PERMISSION_SIZE;
      sig.m = new SessionPermissions[](j);
    }

    while (bo < bn.length) {

      uint256 be;
      (be, bo) = bn.bg(bo);

      uint256 bx = (be & 0xf0) >> 4;


      if (bx == FLAG_PERMISSIONS) {
        SessionPermissions memory w;
        uint256 aj = bo;


        (w.bs, bo) = bn.am(bo);


        (w.chainId, bo) = bn.an(bo);


        (w.ax, bo) = bn.an(bo);


        (w.bi, bo) = bn.ar(bo);


        (w.al, bo) = i(bn, bo);


        {
          bytes32 aa = c(bn[aj:bo]);
          sig.bc =
            sig.bc != bytes32(0) ? LibOptim.at(sig.bc, aa) : aa;
        }


        sig.m[u++] = w;
        continue;
      }


      if (bx == FLAG_NODE) {

        bytes32 by;
        (by, bo) = bn.ao(bo);


        sig.bc = sig.bc != bytes32(0) ? LibOptim.at(sig.bc, by) : by;

        continue;
      }


      if (bx == FLAG_BRANCH) {

        uint256 bw;
        {
          uint256 bh = uint8(be & 0x0f);
          (bw, bo) = bn.ba(bo, bh);
        }

        uint256 bm = bo + bw;
        (DecodedSignature memory bd, bool k) = f(bn[bo:bm]);
        bo = bm;


        if (k) {
          if (ai) {

            revert SessionErrors.InvalidBlacklist();
          }
          ai = true;
          sig.n = bd.n;
        }


        if (bd.ad != address(0)) {
          if (sig.ad != address(0)) {

            revert SessionErrors.InvalidIdentitySigner();
          }
          sig.ad = bd.ad;
        }


        for (uint256 i = 0; i < bd.m.length; i++) {
          sig.m[u++] = bd.m[i];
        }


        sig.bc =
          sig.bc != bytes32(0) ? LibOptim.at(sig.bc, bd.bc) : bd.bc;

        continue;
      }


      if (bx == FLAG_BLACKLIST) {
        if (ai) {

          revert SessionErrors.InvalidBlacklist();
        }
        ai = true;


        uint256 ab = uint256(be & 0x0f);
        if (ab == 0x0f) {

          (ab, bo) = bn.as(bo);
        }
        uint256 aj = bo;


        sig.n = new address[](ab);
        address x;
        for (uint256 i = 0; i < ab; i++) {
          (sig.n[i], bo) = bn.am(bo);
          if (sig.n[i] < x) {
            revert SessionErrors.InvalidBlacklistUnsorted();
          }
          x = sig.n[i];
        }


        bytes32 af = e(bn[aj:bo]);
        sig.bc = sig.bc != bytes32(0) ? LibOptim.at(sig.bc, af) : af;

        continue;
      }


      if (bx == FLAG_IDENTITY_SIGNER) {
        if (sig.ad != address(0)) {

          revert SessionErrors.InvalidIdentitySigner();
        }
        (sig.ad, bo) = bn.am(bo);


        bytes32 l = b(sig.ad);
        sig.bc =
          sig.bc != bytes32(0) ? LibOptim.at(sig.bc, l) : l;

        continue;
      }

      revert SessionErrors.InvalidNodeType(bx);
    }

    {

      SessionPermissions[] memory al = sig.m;
      assembly {
        mstore(al, u)
      }
    }

    return (sig, ai);
  }


  function i(
    bytes calldata bn,
    uint256 bo
  ) internal pure returns (Permission[] memory al, uint256 ay) {
    uint256 length;
    (length, bo) = bn.bg(bo);
    al = new Permission[](length);
    for (uint256 i = 0; i < length; i++) {
      (al[i], bo) = LibPermission.ae(bn, bo);
    }
    return (al, bo);
  }


  function c(
    bytes calldata h
  ) internal pure returns (bytes32) {
    return bf(abi.ak(uint8(FLAG_PERMISSIONS), h));
  }


  function e(
    bytes calldata t
  ) internal pure returns (bytes32) {
    return bf(abi.ak(uint8(FLAG_BLACKLIST), t));
  }


  function b(
    address ad
  ) internal pure returns (bytes32) {
    return bf(abi.ak(uint8(FLAG_IDENTITY_SIGNER), ad));
  }


  function a(
    Payload.Decoded calldata bq,
    uint256 bp
  ) public view returns (bytes32 bk) {
    return bf(
      abi.ak(
        bq.bb ? 0 : block.chainid,
        bq.bt,
        bq.bv,
        bp,
        Payload.bl(bq.bu[bp])
      )
    );
  }

}
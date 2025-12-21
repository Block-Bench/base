pragma solidity ^0.8.27;

import { LibBytes } from "../../utils/LibBytes.sol";
import { LibOptim } from "../../utils/LibOptim.sol";
import { Payload } from "../Payload.sol";

import { ICheckpointer, Snapshot } from "../interfaces/ICheckpointer.sol";
import { IERC1271, IERC1271_MAGIC_VALUE_HASH } from "../interfaces/IERC1271.sol";
import { ISapient, ISapientCompact } from "../interfaces/ISapient.sol";

using LibBytes for bytes;
using Payload for Payload.Decoded;


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


  error LowWeightChainedSignature(bytes aq, uint256 an, uint256 bg);

  error InvalidERC1271Signature(bytes32 bk, address bm, bytes aq);

  error WrongChainedCheckpointOrder(uint256 n, uint256 ai);

  error UnusedSnapshot(Snapshot at);

  error InvalidSignatureFlag(uint256 bq);

  function d(address bs, uint256 bg) internal pure returns (bytes32) {
    return ay(abi.ae("Sequence signer:\n", bs, bg));
  }

  function q(bytes32 br, uint256 an, uint256 bg) internal pure returns (bytes32) {
    return ay(abi.ae("Sequence nested config:\n", br, an, bg));
  }

  function o(address bs, uint256 bg, bytes32 al) internal pure returns (bytes32) {
    return ay(abi.ae("Sequence sapient config:\n", bs, bg, al));
  }

  function c(
    bytes32 ar
  ) internal pure returns (bytes32) {
    return ay(abi.ae("Sequence static digest:\n", ar));
  }

  function b(
    bytes32 f
  ) internal pure returns (bytes32) {
    return ay(abi.ae("Sequence any address subdigest:\n", f));
  }

  function bf(
    Payload.Decoded memory bc,
    bytes calldata aq,
    bool h,
    address z
  ) internal view returns (uint256 ba, uint256 bn, bytes32 aw, uint256 ap, bytes32 bo) {

    (uint256 y, uint256 bp) = aq.w();


    Snapshot memory be;


    if (y & 0x40 == 0x40 && z == address(0)) {


      (z, bp) = aq.af(bp);

      if (!h) {

        uint256 g;
        (g, bp) = aq.ao(bp);


        bytes memory k = aq[bp:bp + g];


        be = ICheckpointer(z).ag(address(this), k);

        bp += g;
      }
    }


    if (y & 0x01 == 0x01) {
      return v(bc, z, be, aq[bp:]);
    }


    bc.av = y & 0x02 == 0x02;

    {

      uint256 s = (y & 0x1c) >> 2;
      (ap, bp) = aq.au(bp, s);
    }


    {
      uint256 x = ((y & 0x20) >> 5) + 1;
      (ba, bp) = aq.au(bp, x);
    }


    bo = bc.bx();
    (bn, aw) = aa(bc, bo, aq[bp:]);

    aw = LibOptim.am(aw, bytes32(ba));
    aw = LibOptim.am(aw, bytes32(ap));
    aw = LibOptim.am(aw, bytes32(uint256(uint160(z))));


    if (be.aw != bytes32(0) && be.aw != aw && ap <= be.ap) {
      revert UnusedSnapshot(be);
    }
  }

  function v(
    Payload.Decoded memory bc,
    address z,
    Snapshot memory at,
    bytes calldata aq
  ) internal view returns (uint256 ba, uint256 bn, bytes32 aw, uint256 ap, bytes32 bo) {
    Payload.Decoded memory ab;
    ab.bw = Payload.KIND_CONFIG_UPDATE;

    uint256 bp;
    uint256 p = type(uint256).ca;

    while (bp < aq.length) {
      uint256 bj;

      {
        uint256 bl;
        (bl, bp) = aq.ao(bp);
        bj = bl + bp;
      }

      address ac = bj == aq.length ? z : address(0);

      if (p == type(uint256).ca) {
        (ba, bn, aw, ap, bo) =
          bf(bc, aq[bp:bj], true, ac);
      } else {
        (ba, bn, aw, ap,) =
          bf(ab, aq[bp:bj], true, ac);
      }

      if (bn < ba) {
        revert LowWeightChainedSignature(aq[bp:bj], ba, bn);
      }
      bp = bj;

      if (at.aw == aw) {
        at.aw = bytes32(0);
      }

      if (ap >= p) {
        revert WrongChainedCheckpointOrder(ap, p);
      }

      ab.aw = aw;
      p = ap;
    }

    if (at.aw != bytes32(0) && ap <= at.ap) {
      revert UnusedSnapshot(at);
    }
  }

  function aa(
    Payload.Decoded memory bc,
    bytes32 bk,
    bytes calldata aq
  ) internal view returns (uint256 bn, bytes32 bv) {
    unchecked {
      uint256 bp;


      while (bp < aq.length) {


        uint256 ax;
        (ax, bp) = aq.bb(bp);


        uint256 bu = (ax & 0xf0) >> 4;


        if (bu == FLAG_SIGNATURE_HASH) {


          uint8 aj = uint8(ax & 0x0f);
          if (aj == 0) {
            (aj, bp) = aq.bb(bp);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, bp) = aq.r(bp);

          address bz = as(bk, v, r, s);

          bn += aj;
          bytes32 by = d(bz, aj);
          bv = bv != bytes32(0) ? LibOptim.am(bv, by) : by;
          continue;
        }


        if (bu == FLAG_ADDRESS) {


          uint8 aj = uint8(ax & 0x0f);
          if (aj == 0) {
            (aj, bp) = aq.bb(bp);
          }


          address bz;
          (bz, bp) = aq.af(bp);


          bytes32 by = d(bz, aj);
          bv = bv != bytes32(0) ? LibOptim.am(bv, by) : by;
          continue;
        }


        if (bu == FLAG_SIGNATURE_ERC1271) {


          uint8 aj = uint8(ax & 0x03);
          if (aj == 0) {
            (aj, bp) = aq.bb(bp);
          }


          address bz;
          (bz, bp) = aq.af(bp);


          uint256 bd = uint8(ax & 0x0c) >> 2;
          uint256 bt;
          (bt, bp) = aq.au(bp, bd);


          uint256 bj = bp + bt;


          if (IERC1271(bz).m(bk, aq[bp:bj]) != IERC1271_MAGIC_VALUE_HASH) {
            revert InvalidERC1271Signature(bk, bz, aq[bp:bj]);
          }
          bp = bj;

          bn += aj;
          bytes32 by = d(bz, aj);
          bv = bv != bytes32(0) ? LibOptim.am(bv, by) : by;
          continue;
        }


        if (bu == FLAG_NODE) {


          bytes32 by;
          (by, bp) = aq.ah(bp);
          bv = bv != bytes32(0) ? LibOptim.am(bv, by) : by;
          continue;
        }


        if (bu == FLAG_BRANCH) {


          uint256 bd = uint8(ax & 0x0f);
          uint256 bt;
          (bt, bp) = aq.au(bp, bd);


          uint256 bj = bp + bt;

          (uint256 bi, bytes32 by) = aa(bc, bk, aq[bp:bj]);
          bp = bj;

          bn += bi;
          bv = LibOptim.am(bv, by);
          continue;
        }


        if (bu == FLAG_NESTED) {


          uint256 u = uint8(ax & 0x0c) >> 2;
          if (u == 0) {
            (u, bp) = aq.bb(bp);
          }

          uint256 i = uint8(ax & 0x03);
          if (i == 0) {
            (i, bp) = aq.ak(bp);
          }

          uint256 bt;
          (bt, bp) = aq.ao(bp);
          uint256 bj = bp + bt;

          (uint256 t, bytes32 ad) = aa(bc, bk, aq[bp:bj]);
          bp = bj;

          if (t >= i) {
            bn += u;
          }

          bytes32 by = q(ad, i, u);
          bv = bv != bytes32(0) ? LibOptim.am(bv, by) : by;
          continue;
        }


        if (bu == FLAG_SUBDIGEST) {


          bytes32 az;
          (az, bp) = aq.ah(bp);
          if (az == bk) {
            bn = type(uint256).ca;
          }

          bytes32 by = c(az);
          bv = bv != bytes32(0) ? LibOptim.am(bv, by) : by;
          continue;
        }


        if (bu == FLAG_SIGNATURE_ETH_SIGN) {


          uint8 aj = uint8(ax & 0x0f);
          if (aj == 0) {
            (aj, bp) = aq.bb(bp);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, bp) = aq.r(bp);

          address bz = as(ay(abi.ae("\x19Ethereum Signed Message:\n32", bk)), v, r, s);

          bn += aj;
          bytes32 by = d(bz, aj);
          bv = bv != bytes32(0) ? LibOptim.am(bv, by) : by;
          continue;
        }


        if (bu == FLAG_SIGNATURE_ANY_ADDRESS_SUBDIGEST) {


          bytes32 az;
          (az, bp) = aq.ah(bp);
          bytes32 j = bc.bh(address(0));
          if (az == j) {
            bn = type(uint256).ca;
          }

          bytes32 by = b(az);
          bv = bv != bytes32(0) ? LibOptim.am(bv, by) : by;
          continue;
        }


        if (bu == FLAG_SIGNATURE_SAPIENT) {


          uint8 aj = uint8(ax & 0x03);
          if (aj == 0) {
            (aj, bp) = aq.bb(bp);
          }

          address bz;
          (bz, bp) = aq.af(bp);


          uint256 bt;
          {
            uint256 bd = uint8(ax & 0x0c) >> 2;
            (bt, bp) = aq.au(bp, bd);
          }


          uint256 bj = bp + bt;


          bytes32 l = ISapient(bz).e(bc, aq[bp:bj]);
          bp = bj;


          bn += aj;
          bytes32 by = o(bz, aj, l);
          bv = bv != bytes32(0) ? LibOptim.am(bv, by) : by;
          continue;
        }


        if (bu == FLAG_SIGNATURE_SAPIENT_COMPACT) {


          uint8 aj = uint8(ax & 0x03);
          if (aj == 0) {
            (aj, bp) = aq.bb(bp);
          }

          address bz;
          (bz, bp) = aq.af(bp);


          uint256 bd = uint8(ax & 0x0c) >> 2;
          uint256 bt;
          (bt, bp) = aq.au(bp, bd);


          uint256 bj = bp + bt;


          bytes32 l =
            ISapientCompact(bz).a(bk, aq[bp:bj]);
          bp = bj;

          bn += aj;
          bytes32 by = o(bz, aj, l);
          bv = bv != bytes32(0) ? LibOptim.am(bv, by) : by;
          continue;
        }

        revert InvalidSignatureFlag(bu);
      }
    }
  }

}
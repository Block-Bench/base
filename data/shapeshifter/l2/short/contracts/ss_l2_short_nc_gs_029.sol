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


  error LowWeightChainedSignature(bytes ap, uint256 aj, uint256 bh);

  error InvalidERC1271Signature(bytes32 bl, address bi, bytes ap);

  error WrongChainedCheckpointOrder(uint256 o, uint256 af);

  error UnusedSnapshot(Snapshot ay);

  error InvalidSignatureFlag(uint256 bs);

  function d(address bq, uint256 bh) internal pure returns (bytes32) {
    return au(abi.ac("Sequence signer:\n", bq, bh));
  }

  function w(bytes32 br, uint256 aj, uint256 bh) internal pure returns (bytes32) {
    return au(abi.ac("Sequence nested config:\n", br, aj, bh));
  }

  function n(address bq, uint256 bh, bytes32 ar) internal pure returns (bytes32) {
    return au(abi.ac("Sequence sapient config:\n", bq, bh, ar));
  }

  function c(
    bytes32 ao
  ) internal pure returns (bytes32) {
    return au(abi.ac("Sequence static digest:\n", ao));
  }

  function b(
    bytes32 f
  ) internal pure returns (bytes32) {
    return au(abi.ac("Sequence any address subdigest:\n", f));
  }

  function bj(
    Payload.Decoded memory be,
    bytes calldata ap,
    bool h,
    address ab
  ) internal view returns (uint256 av, uint256 bp, bytes32 bb, uint256 an, bytes32 bn) {

    (uint256 y, uint256 bo) = ap.s();


    Snapshot memory bc;


    if (y & 0x40 == 0x40 && ab == address(0)) {


      (ab, bo) = ap.ah(bo);

      if (!h) {

        uint256 g;
        (g, bo) = ap.am(bo);


        bytes memory l = ap[bo:bo + g];


        bc = ICheckpointer(ab).ag(address(this), l);

        bo += g;
      }
    }


    if (y & 0x01 == 0x01) {
      return t(be, ab, bc, ap[bo:]);
    }


    be.aw = y & 0x02 == 0x02;

    {

      uint256 r = (y & 0x1c) >> 2;
      (an, bo) = ap.ba(bo, r);
    }


    {
      uint256 z = ((y & 0x20) >> 5) + 1;
      (av, bo) = ap.ba(bo, z);
    }


    bn = be.bw();
    (bp, bb) = x(be, bn, ap[bo:]);

    bb = LibOptim.al(bb, bytes32(av));
    bb = LibOptim.al(bb, bytes32(an));
    bb = LibOptim.al(bb, bytes32(uint256(uint160(ab))));


    if (bc.bb != bytes32(0) && bc.bb != bb && an <= bc.an) {
      revert UnusedSnapshot(bc);
    }
  }

  function t(
    Payload.Decoded memory be,
    address ab,
    Snapshot memory ay,
    bytes calldata ap
  ) internal view returns (uint256 av, uint256 bp, bytes32 bb, uint256 an, bytes32 bn) {
    Payload.Decoded memory aa;
    aa.bu = Payload.KIND_CONFIG_UPDATE;

    uint256 bo;
    uint256 q = type(uint256).ca;

    while (bo < ap.length) {
      uint256 bm;

      {
        uint256 bk;
        (bk, bo) = ap.am(bo);
        bm = bk + bo;
      }

      address ae = bm == ap.length ? ab : address(0);

      if (q == type(uint256).ca) {
        (av, bp, bb, an, bn) =
          bj(be, ap[bo:bm], true, ae);
      } else {
        (av, bp, bb, an,) =
          bj(aa, ap[bo:bm], true, ae);
      }

      if (bp < av) {
        revert LowWeightChainedSignature(ap[bo:bm], av, bp);
      }
      bo = bm;

      if (ay.bb == bb) {
        ay.bb = bytes32(0);
      }

      if (an >= q) {
        revert WrongChainedCheckpointOrder(an, q);
      }

      aa.bb = bb;
      q = an;
    }

    if (ay.bb != bytes32(0) && an <= ay.an) {
      revert UnusedSnapshot(ay);
    }
  }

  function x(
    Payload.Decoded memory be,
    bytes32 bl,
    bytes calldata ap
  ) internal view returns (uint256 bp, bytes32 bv) {
    unchecked {
      uint256 bo;


      while (bo < ap.length) {


        uint256 at;
        (at, bo) = ap.ax(bo);


        uint256 bt = (at & 0xf0) >> 4;


        if (bt == FLAG_SIGNATURE_HASH) {


          uint8 aq = uint8(at & 0x0f);
          if (aq == 0) {
            (aq, bo) = ap.ax(bo);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, bo) = ap.p(bo);

          address by = az(bl, v, r, s);

          bp += aq;
          bytes32 bx = d(by, aq);
          bv = bv != bytes32(0) ? LibOptim.al(bv, bx) : bx;
          continue;
        }


        if (bt == FLAG_ADDRESS) {


          uint8 aq = uint8(at & 0x0f);
          if (aq == 0) {
            (aq, bo) = ap.ax(bo);
          }


          address by;
          (by, bo) = ap.ah(bo);


          bytes32 bx = d(by, aq);
          bv = bv != bytes32(0) ? LibOptim.al(bv, bx) : bx;
          continue;
        }


        if (bt == FLAG_SIGNATURE_ERC1271) {


          uint8 aq = uint8(at & 0x03);
          if (aq == 0) {
            (aq, bo) = ap.ax(bo);
          }


          address by;
          (by, bo) = ap.ah(bo);


          uint256 bd = uint8(at & 0x0c) >> 2;
          uint256 bz;
          (bz, bo) = ap.ba(bo, bd);


          uint256 bm = bo + bz;


          if (IERC1271(by).j(bl, ap[bo:bm]) != IERC1271_MAGIC_VALUE_HASH) {
            revert InvalidERC1271Signature(bl, by, ap[bo:bm]);
          }
          bo = bm;

          bp += aq;
          bytes32 bx = d(by, aq);
          bv = bv != bytes32(0) ? LibOptim.al(bv, bx) : bx;
          continue;
        }


        if (bt == FLAG_NODE) {


          bytes32 bx;
          (bx, bo) = ap.ai(bo);
          bv = bv != bytes32(0) ? LibOptim.al(bv, bx) : bx;
          continue;
        }


        if (bt == FLAG_BRANCH) {


          uint256 bd = uint8(at & 0x0f);
          uint256 bz;
          (bz, bo) = ap.ba(bo, bd);


          uint256 bm = bo + bz;

          (uint256 bf, bytes32 bx) = x(be, bl, ap[bo:bm]);
          bo = bm;

          bp += bf;
          bv = LibOptim.al(bv, bx);
          continue;
        }


        if (bt == FLAG_NESTED) {


          uint256 u = uint8(at & 0x0c) >> 2;
          if (u == 0) {
            (u, bo) = ap.ax(bo);
          }

          uint256 i = uint8(at & 0x03);
          if (i == 0) {
            (i, bo) = ap.ak(bo);
          }

          uint256 bz;
          (bz, bo) = ap.am(bo);
          uint256 bm = bo + bz;

          (uint256 v, bytes32 ad) = x(be, bl, ap[bo:bm]);
          bo = bm;

          if (v >= i) {
            bp += u;
          }

          bytes32 bx = w(ad, i, u);
          bv = bv != bytes32(0) ? LibOptim.al(bv, bx) : bx;
          continue;
        }


        if (bt == FLAG_SUBDIGEST) {


          bytes32 as;
          (as, bo) = ap.ai(bo);
          if (as == bl) {
            bp = type(uint256).ca;
          }

          bytes32 bx = c(as);
          bv = bv != bytes32(0) ? LibOptim.al(bv, bx) : bx;
          continue;
        }


        if (bt == FLAG_SIGNATURE_ETH_SIGN) {


          uint8 aq = uint8(at & 0x0f);
          if (aq == 0) {
            (aq, bo) = ap.ax(bo);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, bo) = ap.p(bo);

          address by = az(au(abi.ac("\x19Ethereum Signed Message:\n32", bl)), v, r, s);

          bp += aq;
          bytes32 bx = d(by, aq);
          bv = bv != bytes32(0) ? LibOptim.al(bv, bx) : bx;
          continue;
        }


        if (bt == FLAG_SIGNATURE_ANY_ADDRESS_SUBDIGEST) {


          bytes32 as;
          (as, bo) = ap.ai(bo);
          bytes32 k = be.bg(address(0));
          if (as == k) {
            bp = type(uint256).ca;
          }

          bytes32 bx = b(as);
          bv = bv != bytes32(0) ? LibOptim.al(bv, bx) : bx;
          continue;
        }


        if (bt == FLAG_SIGNATURE_SAPIENT) {


          uint8 aq = uint8(at & 0x03);
          if (aq == 0) {
            (aq, bo) = ap.ax(bo);
          }

          address by;
          (by, bo) = ap.ah(bo);


          uint256 bz;
          {
            uint256 bd = uint8(at & 0x0c) >> 2;
            (bz, bo) = ap.ba(bo, bd);
          }


          uint256 bm = bo + bz;


          bytes32 m = ISapient(by).e(be, ap[bo:bm]);
          bo = bm;


          bp += aq;
          bytes32 bx = n(by, aq, m);
          bv = bv != bytes32(0) ? LibOptim.al(bv, bx) : bx;
          continue;
        }


        if (bt == FLAG_SIGNATURE_SAPIENT_COMPACT) {


          uint8 aq = uint8(at & 0x03);
          if (aq == 0) {
            (aq, bo) = ap.ax(bo);
          }

          address by;
          (by, bo) = ap.ah(bo);


          uint256 bd = uint8(at & 0x0c) >> 2;
          uint256 bz;
          (bz, bo) = ap.ba(bo, bd);


          uint256 bm = bo + bz;


          bytes32 m =
            ISapientCompact(by).a(bl, ap[bo:bm]);
          bo = bm;

          bp += aq;
          bytes32 bx = n(by, aq, m);
          bv = bv != bytes32(0) ? LibOptim.al(bv, bx) : bx;
          continue;
        }

        revert InvalidSignatureFlag(bt);
      }
    }
  }

}
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
  error LowWeightChainedSignature(bytes ak, uint256 am, uint256 bm);
  /// @notice Error thrown when the ERC1271 signature is invalid
  error InvalidERC1271Signature(bytes32 bh, address bj, bytes ak);
  /// @notice Error thrown when the checkpoint order is wrong
  error WrongChainedCheckpointOrder(uint256 o, uint256 ag);
  /// @notice Error thrown when the snapshot is unused
  error UnusedSnapshot(Snapshot av);
  /// @notice Error thrown when the signature flag is invalid
  error InvalidSignatureFlag(uint256 bq);

  function d(address br, uint256 bm) internal pure returns (bytes32) {
    return au(abi.ac("Sequence signer:\n", br, bm));
  }

  function p(bytes32 bs, uint256 am, uint256 bm) internal pure returns (bytes32) {
    return au(abi.ac("Sequence nested config:\n", bs, am, bm));
  }

  function n(address br, uint256 bm, bytes32 aq) internal pure returns (bytes32) {
    return au(abi.ac("Sequence sapient config:\n", br, bm, aq));
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

  function bf(
    Payload.Decoded memory be,
    bytes calldata ak,
    bool h,
    address z
  ) internal view returns (uint256 ax, uint256 bn, bytes32 ba, uint256 ar, bytes32 bo) {
    // First byte is the signature flag
    (uint256 y, uint256 bp) = ak.t();

    // The possible flags are:
    // - 0000 00XX (bits [1..0]): signature type (00 = normal, 01/11 = chained, 10 = no chain id)
    // - 000X XX00 (bits [4..2]): checkpoint size (00 = 0 bytes, 001 = 1 byte, 010 = 2 bytes...)
    // - 00X0 0000 (bit [5]): threshold size (0 = 1 byte, 1 = 2 bytes)
    // - 0X00 0000 (bit [6]): set if imageHash checkpointer is used
    // - X000 0000 (bit [7]): reserved by base-auth

    Snapshot memory bc;

    // Recover the imageHash checkpointer if any
    // but checkpointer passed as argument takes precedence
    // since it can be defined by the chained signatures
    if (y & 0x40 == 0x40 && z == address(0)) {
      // Override the checkpointer
      // not ideal, but we don't have much room in the stack
      (z, bp) = ak.ah(bp);

      if (!h) {
        // Next 3 bytes determine the checkpointer data size
        uint256 g;
        (g, bp) = ak.aj(bp);

        // Read the checkpointer data
        bytes memory j = ak[bp:bp + g];

        // Call the middleware
        bc = ICheckpointer(z).ai(address(this), j);

        bp += g;
      }
    }

    // If signature type is 01 or 11 we do a chained signature
    if (y & 0x01 == 0x01) {
      return s(be, z, bc, ak[bp:]);
    }

    // If the signature type is 10 we do a no chain id signature
    be.az = y & 0x02 == 0x02;

    {
      // Recover the checkpoint using the size defined by the flag
      uint256 v = (y & 0x1c) >> 2;
      (ar, bp) = ak.as(bp, v);
    }

    // Recover the threshold, using the flag for the size
    {
      uint256 x = ((y & 0x20) >> 5) + 1;
      (ax, bp) = ak.as(bp, x);
    }

    // Recover the tree
    bo = be.bz();
    (bn, ba) = ab(be, bo, ak[bp:]);

    ba = LibOptim.al(ba, bytes32(ax));
    ba = LibOptim.al(ba, bytes32(ar));
    ba = LibOptim.al(ba, bytes32(uint256(uint160(z))));

    // If the snapshot is used, either the imageHash must match
    // or the checkpoint must be greater than the snapshot checkpoint
    if (bc.ba != bytes32(0) && bc.ba != ba && ar <= bc.ar) {
      revert UnusedSnapshot(bc);
    }
  }

  function s(
    Payload.Decoded memory be,
    address z,
    Snapshot memory av,
    bytes calldata ak
  ) internal view returns (uint256 ax, uint256 bn, bytes32 ba, uint256 ar, bytes32 bo) {
    Payload.Decoded memory aa;
    aa.bu = Payload.KIND_CONFIG_UPDATE;

    uint256 bp;
    uint256 u = type(uint256).ca;

    while (bp < ak.length) {
      uint256 bl;

      {
        uint256 bi;
        (bi, bp) = ak.aj(bp);
        bl = bi + bp;
      }

      address ad = bl == ak.length ? z : address(0);

      if (u == type(uint256).ca) {
        (ax, bn, ba, ar, bo) =
          bf(be, ak[bp:bl], true, ad);
      } else {
        (ax, bn, ba, ar,) =
          bf(aa, ak[bp:bl], true, ad);
      }

      if (bn < ax) {
        revert LowWeightChainedSignature(ak[bp:bl], ax, bn);
      }
      bp = bl;

      if (av.ba == ba) {
        av.ba = bytes32(0);
      }

      if (ar >= u) {
        revert WrongChainedCheckpointOrder(ar, u);
      }

      aa.ba = ba;
      u = ar;
    }

    if (av.ba != bytes32(0) && ar <= av.ar) {
      revert UnusedSnapshot(av);
    }
  }

  function ab(
    Payload.Decoded memory be,
    bytes32 bh,
    bytes calldata ak
  ) internal view returns (uint256 bn, bytes32 bw) {
    unchecked {
      uint256 bp;

      // Iterate until the image is completed
      while (bp < ak.length) {
        // The first byte is half flag (the top nibble)
        // and the second set of 4 bits can freely be used by the part

        // Read next item type
        uint256 bb;
        (bb, bp) = ak.at(bp);

        // The top 4 bits are the flag
        uint256 bv = (bb & 0xf0) >> 4;

        // Signature hash (0x00)
        if (bv == FLAG_SIGNATURE_HASH) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, ..., 1111 = 15)
          // We read 64 bytes for an ERC-2098 compact signature (r, yParityAndS).
          // The top bit of yParityAndS is yParity, the remaining 255 bits are s.

          uint8 an = uint8(bb & 0x0f);
          if (an == 0) {
            (an, bp) = ak.at(bp);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, bp) = ak.q(bp);

          address bt = aw(bh, v, r, s);

          bn += an;
          bytes32 by = d(bt, an);
          bw = bw != bytes32(0) ? LibOptim.al(bw, by) : by;
          continue;
        }

        // Address (0x01) (without signature)
        if (bv == FLAG_ADDRESS) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, 0010 = 2, ...)

          // Read weight
          uint8 an = uint8(bb & 0x0f);
          if (an == 0) {
            (an, bp) = ak.at(bp);
          }

          // Read address
          address bt;
          (bt, bp) = ak.ah(bp);

          // Compute the merkle root WITHOUT adding the weight
          bytes32 by = d(bt, an);
          bw = bw != bytes32(0) ? LibOptim.al(bw, by) : by;
          continue;
        }

        // Signature ERC1271 (0x02)
        if (bv == FLAG_SIGNATURE_ERC1271) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read weight
          uint8 an = uint8(bb & 0x03);
          if (an == 0) {
            (an, bp) = ak.at(bp);
          }

          // Read signer
          address bt;
          (bt, bp) = ak.ah(bp);

          // Read signature size
          uint256 bd = uint8(bb & 0x0c) >> 2;
          uint256 bx;
          (bx, bp) = ak.as(bp, bd);

          // Read dynamic size signature
          uint256 bl = bp + bx;

          // Call the ERC1271 contract to check if the signature is valid
          if (IERC1271(bt).k(bh, ak[bp:bl]) != IERC1271_MAGIC_VALUE_HASH) {
            revert InvalidERC1271Signature(bh, bt, ak[bp:bl]);
          }
          bp = bl;
          // Add the weight and compute the merkle root
          bn += an;
          bytes32 by = d(bt, an);
          bw = bw != bytes32(0) ? LibOptim.al(bw, by) : by;
          continue;
        }

        // Node (0x03)
        if (bv == FLAG_NODE) {
          // Free bits left unused

          // Read node hash
          bytes32 by;
          (by, bp) = ak.af(bp);
          bw = bw != bytes32(0) ? LibOptim.al(bw, by) : by;
          continue;
        }

        // Branch (0x04)
        if (bv == FLAG_BRANCH) {
          // Free bits layout:
          // - XXXX : Size size (0000 = 0 byte, 0001 = 1 byte, 0010 = 2 bytes, ...)

          // Read size
          uint256 bd = uint8(bb & 0x0f);
          uint256 bx;
          (bx, bp) = ak.as(bp, bd);

          // Enter a branch of the signature merkle tree
          uint256 bl = bp + bx;

          (uint256 bk, bytes32 by) = ab(be, bh, ak[bp:bl]);
          bp = bl;

          bn += bk;
          bw = LibOptim.al(bw, by);
          continue;
        }

        // Nested (0x06)
        if (bv == FLAG_NESTED) {
          // Unused free bits:
          // - XX00 : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)
          // - 00XX : Threshold (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Enter a branch of the signature merkle tree
          // but with an internal threshold and an external fixed weight
          uint256 w = uint8(bb & 0x0c) >> 2;
          if (w == 0) {
            (w, bp) = ak.at(bp);
          }

          uint256 i = uint8(bb & 0x03);
          if (i == 0) {
            (i, bp) = ak.ap(bp);
          }

          uint256 bx;
          (bx, bp) = ak.aj(bp);
          uint256 bl = bp + bx;

          (uint256 r, bytes32 ae) = ab(be, bh, ak[bp:bl]);
          bp = bl;

          if (r >= i) {
            bn += w;
          }

          bytes32 by = p(ae, i, w);
          bw = bw != bytes32(0) ? LibOptim.al(bw, by) : by;
          continue;
        }

        // Subdigest (0x05)
        if (bv == FLAG_SUBDIGEST) {
          // Free bits left unused

          // A hardcoded always accepted digest
          // it pushes the weight to the maximum
          bytes32 ay;
          (ay, bp) = ak.af(bp);
          if (ay == bh) {
            bn = type(uint256).ca;
          }

          bytes32 by = c(ay);
          bw = bw != bytes32(0) ? LibOptim.al(bw, by) : by;
          continue;
        }

        // Signature ETH Sign (0x07)
        if (bv == FLAG_SIGNATURE_ETH_SIGN) {
          // Free bits layout:
          // - bits [3..0]: Weight (0000 = dynamic, 0001 = 1, ..., 1111 = 15)
          // We read 64 bytes for an ERC-2098 compact signature (r, yParityAndS).
          // The top bit of yParityAndS is yParity, the remaining 255 bits are s.

          uint8 an = uint8(bb & 0x0f);
          if (an == 0) {
            (an, bp) = ak.at(bp);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, bp) = ak.q(bp);

          address bt = aw(au(abi.ac("\x19Ethereum Signed Message:\n32", bh)), v, r, s);

          bn += an;
          bytes32 by = d(bt, an);
          bw = bw != bytes32(0) ? LibOptim.al(bw, by) : by;
          continue;
        }

        // Signature Any address subdigest (0x08)
        // similar to subdigest, but allows for counter-factual payloads
        if (bv == FLAG_SIGNATURE_ANY_ADDRESS_SUBDIGEST) {
          // Free bits left unused

          // A hardcoded always accepted digest
          // it pushes the weight to the maximum
          bytes32 ay;
          (ay, bp) = ak.af(bp);
          bytes32 l = be.bg(address(0));
          if (ay == l) {
            bn = type(uint256).ca;
          }

          bytes32 by = b(ay);
          bw = bw != bytes32(0) ? LibOptim.al(bw, by) : by;
          continue;
        }

        // Signature Sapient (0x09)
        if (bv == FLAG_SIGNATURE_SAPIENT) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read signer and weight
          uint8 an = uint8(bb & 0x03);
          if (an == 0) {
            (an, bp) = ak.at(bp);
          }

          address bt;
          (bt, bp) = ak.ah(bp);

          // Read signature size
          uint256 bx;
          {
            uint256 bd = uint8(bb & 0x0c) >> 2;
            (bx, bp) = ak.as(bp, bd);
          }

          // Read dynamic size signature
          uint256 bl = bp + bx;

          // Call the ERC1271 contract to check if the signature is valid
          bytes32 m = ISapient(bt).e(be, ak[bp:bl]);
          bp = bl;

          // Add the weight and compute the merkle root
          bn += an;
          bytes32 by = n(bt, an, m);
          bw = bw != bytes32(0) ? LibOptim.al(bw, by) : by;
          continue;
        }

        // Signature Sapient Compact (0x0A)
        if (bv == FLAG_SIGNATURE_SAPIENT_COMPACT) {
          // Free bits layout:
          // - XX00 : Signature size size (00 = 0 byte, 01 = 1 byte, 10 = 2 bytes, 11 = 3 bytes)
          // - 00XX : Weight (00 = dynamic, 01 = 1, 10 = 2, 11 = 3)

          // Read signer and weight
          uint8 an = uint8(bb & 0x03);
          if (an == 0) {
            (an, bp) = ak.at(bp);
          }

          address bt;
          (bt, bp) = ak.ah(bp);

          // Read signature size
          uint256 bd = uint8(bb & 0x0c) >> 2;
          uint256 bx;
          (bx, bp) = ak.as(bp, bd);

          // Read dynamic size signature
          uint256 bl = bp + bx;

          // Call the Sapient contract to check if the signature is valid
          bytes32 m =
            ISapientCompact(bt).a(bh, ak[bp:bl]);
          bp = bl;
          // Add the weight and compute the merkle root
          bn += an;
          bytes32 by = n(bt, an, m);
          bw = bw != bytes32(0) ? LibOptim.al(bw, by) : by;
          continue;
        }

        revert InvalidSignatureFlag(bv);
      }
    }
  }

}
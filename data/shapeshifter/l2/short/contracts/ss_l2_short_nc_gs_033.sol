pragma solidity ^0.8.27;

import { Payload } from "../Payload.sol";

import { Storage } from "../Storage.sol";
import { IAuth } from "../interfaces/IAuth.sol";
import { IERC1271, IERC1271_MAGIC_VALUE_HASH } from "../interfaces/IERC1271.sol";

import { IPartialAuth } from "../interfaces/IPartialAuth.sol";
import { ISapient } from "../interfaces/ISapient.sol";
import { BaseSig } from "./BaseSig.sol";

import { SelfAuth } from "./SelfAuth.sol";

using Payload for Payload.Decoded;


abstract contract BaseAuth is IAuth, IPartialAuth, ISapient, IERC1271, SelfAuth {


  bytes32 private constant STATIC_SIGNATURE_KEY =
    bytes32(0xc852adf5e97c2fc3b38f405671e91b7af1697ef0287577f227ef10494c2a8e86);


  error InvalidSapientSignature(Payload.Decoded z, bytes t);

  error InvalidSignatureWeight(uint256 v, uint256 ah);

  error InvalidStaticSignatureExpired(bytes32 ai, uint256 ac);

  error InvalidStaticSignatureWrongCaller(bytes32 ai, address ad, address l);


  event StaticSignatureSet(bytes32 al, address aa, uint96 r);

  function c(
    bytes32 al
  ) internal view returns (address, uint256) {
    uint256 ao = uint256(Storage.m(STATIC_SIGNATURE_KEY, al));
    return (address(uint160(ao >> 96)), uint256(uint96(ao)));
  }

  function d(bytes32 al, address aa, uint256 r) internal {
    Storage.k(
      STATIC_SIGNATURE_KEY, al, bytes32(uint256(uint160(aa)) << 96 | (r & 0xffffffffffffffffffffffff))
    );
  }


  function g(
    bytes32 al
  ) external view returns (address, uint256) {
    return c(al);
  }


  function f(bytes32 al, address aa, uint96 r) external ab {
    d(al, aa, r);
    emit StaticSignatureSet(al, aa, r);
  }


  function j(
    bytes32 w
  ) external virtual ab {
    i(w);
  }

  function e(
    Payload.Decoded memory z,
    bytes calldata t
  ) internal view virtual returns (bool ae, bytes32 ak) {

    bytes1 n = t[0];

    if (n & 0x80 == 0x80) {
      ak = z.an();

      (address am, uint256 timestamp) = c(ak);
      if (timestamp <= block.timestamp) {
        revert InvalidStaticSignatureExpired(ak, timestamp);
      }

      if (am != address(0) && am != msg.sender) {
        revert InvalidStaticSignatureWrongCaller(ak, msg.sender, am);
      }

      return (true, ak);
    }


    uint256 x;
    uint256 aj;
    bytes32 y;

    (x, aj, y,, ak) = BaseSig.ag(z, t, false, address(0));


    if (aj < x) {
      revert InvalidSignatureWeight(x, aj);
    }

    ae = p(y);
  }


  function a(
    Payload.Decoded memory z,
    bytes calldata t
  ) external view returns (bytes32) {

    address[] memory o = new address[](z.o.length + 1);

    for (uint256 i = 0; i < z.o.length; i++) {
      o[i] = z.o[i];
    }

    o[z.o.length] = msg.sender;
    z.o = o;

    (bool ae,) = e(z, t);
    if (!ae) {
      revert InvalidSapientSignature(z, t);
    }

    return bytes32(uint256(1));
  }


  function h(bytes32 al, bytes calldata t) external view returns (bytes4) {
    Payload.Decoded memory af = Payload.s(al);

    (bool ae,) = e(af, t);
    if (!ae) {
      return bytes4(0);
    }

    return IERC1271_MAGIC_VALUE_HASH;
  }


  function b(
    Payload.Decoded memory z,
    bytes calldata t
  )
    external
    view
    returns (
      uint256 x,
      uint256 aj,
      bool q,
      bytes32 y,
      uint256 u,
      bytes32 ak
    )
  {
    (x, aj, y, u, ak) = BaseSig.ag(z, t, false, address(0));
    q = p(y);
  }

}
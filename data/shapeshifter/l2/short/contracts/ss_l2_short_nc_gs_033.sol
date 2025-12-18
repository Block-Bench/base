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


  error InvalidSapientSignature(Payload.Decoded ac, bytes r);

  error InvalidSignatureWeight(uint256 t, uint256 ah);

  error InvalidStaticSignatureExpired(bytes32 ae, uint256 ab);

  error InvalidStaticSignatureWrongCaller(bytes32 ae, address ai, address j);


  event StaticSignatureSet(bytes32 al, address z, uint96 v);

  function c(
    bytes32 al
  ) internal view returns (address, uint256) {
    uint256 ao = uint256(Storage.m(STATIC_SIGNATURE_KEY, al));
    return (address(uint160(ao >> 96)), uint256(uint96(ao)));
  }

  function d(bytes32 al, address z, uint256 v) internal {
    Storage.k(
      STATIC_SIGNATURE_KEY, al, bytes32(uint256(uint160(z)) << 96 | (v & 0xffffffffffffffffffffffff))
    );
  }


  function f(
    bytes32 al
  ) external view returns (address, uint256) {
    return c(al);
  }


  function g(bytes32 al, address z, uint96 v) external aa {
    d(al, z, v);
    emit StaticSignatureSet(al, z, v);
  }


  function l(
    bytes32 u
  ) external virtual aa {
    h(u);
  }

  function e(
    Payload.Decoded memory ac,
    bytes calldata r
  ) internal view virtual returns (bool ag, bytes32 aj) {

    bytes1 p = r[0];

    if (p & 0x80 == 0x80) {
      aj = ac.an();

      (address am, uint256 timestamp) = c(aj);
      if (timestamp <= block.timestamp) {
        revert InvalidStaticSignatureExpired(aj, timestamp);
      }

      if (am != address(0) && am != msg.sender) {
        revert InvalidStaticSignatureWrongCaller(aj, msg.sender, am);
      }

      return (true, aj);
    }


    uint256 y;
    uint256 ak;
    bytes32 x;

    (y, ak, x,, aj) = BaseSig.ad(ac, r, false, address(0));


    if (ak < y) {
      revert InvalidSignatureWeight(y, ak);
    }

    ag = o(x);
  }


  function a(
    Payload.Decoded memory ac,
    bytes calldata r
  ) external view returns (bytes32) {

    address[] memory n = new address[](ac.n.length + 1);

    for (uint256 i = 0; i < ac.n.length; i++) {
      n[i] = ac.n[i];
    }

    n[ac.n.length] = msg.sender;
    ac.n = n;

    (bool ag,) = e(ac, r);
    if (!ag) {
      revert InvalidSapientSignature(ac, r);
    }

    return bytes32(uint256(1));
  }


  function i(bytes32 al, bytes calldata r) external view returns (bytes4) {
    Payload.Decoded memory af = Payload.w(al);

    (bool ag,) = e(af, r);
    if (!ag) {
      return bytes4(0);
    }

    return IERC1271_MAGIC_VALUE_HASH;
  }


  function b(
    Payload.Decoded memory ac,
    bytes calldata r
  )
    external
    view
    returns (
      uint256 y,
      uint256 ak,
      bool q,
      bytes32 x,
      uint256 s,
      bytes32 aj
    )
  {
    (y, ak, x, s, aj) = BaseSig.ad(ac, r, false, address(0));
    q = o(x);
  }

}
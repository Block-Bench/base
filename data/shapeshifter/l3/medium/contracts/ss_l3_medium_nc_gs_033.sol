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


  error InvalidSapientSignature(Payload.Decoded _0x67e208, bytes _0xc1a866);

  error InvalidSignatureWeight(uint256 _0x52fb76, uint256 _0x9d3d7b);

  error InvalidStaticSignatureExpired(bytes32 _0xb490a6, uint256 _0xa3f19b);

  error InvalidStaticSignatureWrongCaller(bytes32 _0xb490a6, address _0xe31744, address _0xde1033);


  event StaticSignatureSet(bytes32 _0x1c7686, address _0x40160c, uint96 _0x4ba8ec);

  function _0xafc8c5(
    bytes32 _0x1c7686
  ) internal view returns (address, uint256) {
    uint256 _0xa83d6c = uint256(Storage._0xab8d2a(STATIC_SIGNATURE_KEY, _0x1c7686));
    return (address(uint160(_0xa83d6c >> 96)), uint256(uint96(_0xa83d6c)));
  }

  function _0x9131ec(bytes32 _0x1c7686, address _0x40160c, uint256 _0x4ba8ec) internal {
    Storage._0x9fcd73(
      STATIC_SIGNATURE_KEY, _0x1c7686, bytes32(uint256(uint160(_0x40160c)) << 96 | (_0x4ba8ec & 0xffffffffffffffffffffffff))
    );
  }


  function _0x162bbd(
    bytes32 _0x1c7686
  ) external view returns (address, uint256) {
    return _0xafc8c5(_0x1c7686);
  }


  function _0x050c5e(bytes32 _0x1c7686, address _0x40160c, uint96 _0x4ba8ec) external _0x4e68f4 {
    _0x9131ec(_0x1c7686, _0x40160c, _0x4ba8ec);
    emit StaticSignatureSet(_0x1c7686, _0x40160c, _0x4ba8ec);
  }


  function _0x5aadc0(
    bytes32 _0x665c80
  ) external virtual _0x4e68f4 {
    _0x9532f4(_0x665c80);
  }

  function _0xf26a2e(
    Payload.Decoded memory _0x67e208,
    bytes calldata _0xc1a866
  ) internal view virtual returns (bool _0x7651d8, bytes32 _0xf04493) {

    bytes1 _0xcd1d4e = _0xc1a866[0];

    if (_0xcd1d4e & 0x80 == 0x80) {
      _0xf04493 = _0x67e208._0x766477();

      (address _0xb24d16, uint256 timestamp) = _0xafc8c5(_0xf04493);
      if (timestamp <= block.timestamp) {
        revert InvalidStaticSignatureExpired(_0xf04493, timestamp);
      }

      if (_0xb24d16 != address(0) && _0xb24d16 != msg.sender) {
        revert InvalidStaticSignatureWrongCaller(_0xf04493, msg.sender, _0xb24d16);
      }

      return (true, _0xf04493);
    }


    uint256 _0x94719b;
    uint256 _0x5c1ef2;
    bytes32 _0x06397d;

    (_0x94719b, _0x5c1ef2, _0x06397d,, _0xf04493) = BaseSig._0xcafa60(_0x67e208, _0xc1a866, false, address(0));


    if (_0x5c1ef2 < _0x94719b) {
      revert InvalidSignatureWeight(_0x94719b, _0x5c1ef2);
    }

    _0x7651d8 = _0x7a46dc(_0x06397d);
  }


  function _0x9e8f73(
    Payload.Decoded memory _0x67e208,
    bytes calldata _0xc1a866
  ) external view returns (bytes32) {

    address[] memory _0x251fde = new address[](_0x67e208._0x251fde.length + 1);

    for (uint256 i = 0; i < _0x67e208._0x251fde.length; i++) {
      _0x251fde[i] = _0x67e208._0x251fde[i];
    }

    _0x251fde[_0x67e208._0x251fde.length] = msg.sender;
    _0x67e208._0x251fde = _0x251fde;

    (bool _0x7651d8,) = _0xf26a2e(_0x67e208, _0xc1a866);
    if (!_0x7651d8) {
      revert InvalidSapientSignature(_0x67e208, _0xc1a866);
    }

    return bytes32(uint256(1));
  }


  function _0x48688f(bytes32 _0x1c7686, bytes calldata _0xc1a866) external view returns (bytes4) {
    Payload.Decoded memory _0x1e8591 = Payload._0x6dbd45(_0x1c7686);

    (bool _0x7651d8,) = _0xf26a2e(_0x1e8591, _0xc1a866);
    if (!_0x7651d8) {
      return bytes4(0);
    }

    return IERC1271_MAGIC_VALUE_HASH;
  }


  function _0x9702f0(
    Payload.Decoded memory _0x67e208,
    bytes calldata _0xc1a866
  )
    external
    view
    returns (
      uint256 _0x94719b,
      uint256 _0x5c1ef2,
      bool _0x9d1b70,
      bytes32 _0x06397d,
      uint256 _0x8d8820,
      bytes32 _0xf04493
    )
  {
    (_0x94719b, _0x5c1ef2, _0x06397d, _0x8d8820, _0xf04493) = BaseSig._0xcafa60(_0x67e208, _0xc1a866, false, address(0));
    _0x9d1b70 = _0x7a46dc(_0x06397d);
  }

}
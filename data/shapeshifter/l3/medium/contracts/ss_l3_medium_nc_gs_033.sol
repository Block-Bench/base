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


  error InvalidSapientSignature(Payload.Decoded _0xa304ed, bytes _0xb9fea9);

  error InvalidSignatureWeight(uint256 _0x5f6f11, uint256 _0xf26162);

  error InvalidStaticSignatureExpired(bytes32 _0x99e167, uint256 _0x6e4fec);

  error InvalidStaticSignatureWrongCaller(bytes32 _0x99e167, address _0x8a6b7a, address _0x1a3348);


  event StaticSignatureSet(bytes32 _0x5271b9, address _0xc6b128, uint96 _0xa528e4);

  function _0xec0dc9(
    bytes32 _0x5271b9
  ) internal view returns (address, uint256) {
    uint256 _0x302fbd = uint256(Storage._0x511f0d(STATIC_SIGNATURE_KEY, _0x5271b9));
    return (address(uint160(_0x302fbd >> 96)), uint256(uint96(_0x302fbd)));
  }

  function _0x3e377c(bytes32 _0x5271b9, address _0xc6b128, uint256 _0xa528e4) internal {
    Storage._0xfd3cc0(
      STATIC_SIGNATURE_KEY, _0x5271b9, bytes32(uint256(uint160(_0xc6b128)) << 96 | (_0xa528e4 & 0xffffffffffffffffffffffff))
    );
  }


  function _0xdf7685(
    bytes32 _0x5271b9
  ) external view returns (address, uint256) {
    return _0xec0dc9(_0x5271b9);
  }


  function _0x14d359(bytes32 _0x5271b9, address _0xc6b128, uint96 _0xa528e4) external _0x70a688 {
    _0x3e377c(_0x5271b9, _0xc6b128, _0xa528e4);
    emit StaticSignatureSet(_0x5271b9, _0xc6b128, _0xa528e4);
  }


  function _0x594969(
    bytes32 _0x913d2f
  ) external virtual _0x70a688 {
    _0x6f33bd(_0x913d2f);
  }

  function _0xebc94b(
    Payload.Decoded memory _0xa304ed,
    bytes calldata _0xb9fea9
  ) internal view virtual returns (bool _0xa6f9b5, bytes32 _0x6b4b12) {

    bytes1 _0xd1b916 = _0xb9fea9[0];

    if (_0xd1b916 & 0x80 == 0x80) {
      _0x6b4b12 = _0xa304ed._0xa1f11f();

      (address _0x334a82, uint256 timestamp) = _0xec0dc9(_0x6b4b12);
      if (timestamp <= block.timestamp) {
        revert InvalidStaticSignatureExpired(_0x6b4b12, timestamp);
      }

      if (_0x334a82 != address(0) && _0x334a82 != msg.sender) {
        revert InvalidStaticSignatureWrongCaller(_0x6b4b12, msg.sender, _0x334a82);
      }

      return (true, _0x6b4b12);
    }


    uint256 _0x2c7a51;
    uint256 _0xb135f8;
    bytes32 _0x8fdbc2;

    (_0x2c7a51, _0xb135f8, _0x8fdbc2,, _0x6b4b12) = BaseSig._0xeadc53(_0xa304ed, _0xb9fea9, false, address(0));


    if (_0xb135f8 < _0x2c7a51) {
      revert InvalidSignatureWeight(_0x2c7a51, _0xb135f8);
    }

    _0xa6f9b5 = _0x7723f7(_0x8fdbc2);
  }


  function _0xd58f70(
    Payload.Decoded memory _0xa304ed,
    bytes calldata _0xb9fea9
  ) external view returns (bytes32) {

    address[] memory _0x8eba7c = new address[](_0xa304ed._0x8eba7c.length + 1);

    for (uint256 i = 0; i < _0xa304ed._0x8eba7c.length; i++) {
      _0x8eba7c[i] = _0xa304ed._0x8eba7c[i];
    }

    _0x8eba7c[_0xa304ed._0x8eba7c.length] = msg.sender;
    _0xa304ed._0x8eba7c = _0x8eba7c;

    (bool _0xa6f9b5,) = _0xebc94b(_0xa304ed, _0xb9fea9);
    if (!_0xa6f9b5) {
      revert InvalidSapientSignature(_0xa304ed, _0xb9fea9);
    }

    return bytes32(uint256(1));
  }


  function _0x8a87e8(bytes32 _0x5271b9, bytes calldata _0xb9fea9) external view returns (bytes4) {
    Payload.Decoded memory _0xda9709 = Payload._0x1c05a6(_0x5271b9);

    (bool _0xa6f9b5,) = _0xebc94b(_0xda9709, _0xb9fea9);
    if (!_0xa6f9b5) {
      return bytes4(0);
    }

    return IERC1271_MAGIC_VALUE_HASH;
  }


  function _0x69b1d1(
    Payload.Decoded memory _0xa304ed,
    bytes calldata _0xb9fea9
  )
    external
    view
    returns (
      uint256 _0x2c7a51,
      uint256 _0xb135f8,
      bool _0xb45489,
      bytes32 _0x8fdbc2,
      uint256 _0x56e7e4,
      bytes32 _0x6b4b12
    )
  {
    (_0x2c7a51, _0xb135f8, _0x8fdbc2, _0x56e7e4, _0x6b4b12) = BaseSig._0xeadc53(_0xa304ed, _0xb9fea9, false, address(0));
    _0xb45489 = _0x7723f7(_0x8fdbc2);
  }

}
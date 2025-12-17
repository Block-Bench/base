// SPDX-License-Identifier: Apache-2.0
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

/// @title BaseAuth
/// @author Agustin Aguilar, Michael Standen
/// @notice Base contract for the auth module
abstract contract BaseAuth is IAuth, IPartialAuth, ISapient, IERC1271, SelfAuth {

  /// @dev keccak256("org.sequence.module.auth.static")
  bytes32 private constant STATIC_SIGNATURE_KEY =
    bytes32(0xc852adf5e97c2fc3b38f405671e91b7af1697ef0287577f227ef10494c2a8e86);

  /// @notice Error thrown when the sapient signature is invalid
  error InvalidSapientSignature(Payload.Decoded _0x615669, bytes _0x66e4a3);
  /// @notice Error thrown when the signature weight is invalid
  error InvalidSignatureWeight(uint256 _0x813d69, uint256 _0xc55d4c);
  /// @notice Error thrown when the static signature has expired
  error InvalidStaticSignatureExpired(bytes32 _0xf32374, uint256 _0x4aa3a0);
  /// @notice Error thrown when the static signature has the wrong caller
  error InvalidStaticSignatureWrongCaller(bytes32 _0xf32374, address _0x58bec2, address _0x12c532);

  /// @notice Event emitted when a static signature is set
  event StaticSignatureSet(bytes32 _0x06318d, address _0x0aaded, uint96 _0x033dcb);

  function _0xf090b0(
    bytes32 _0x06318d
  ) internal view returns (address, uint256) {
    uint256 _0xe49bd2 = uint256(Storage._0x896965(STATIC_SIGNATURE_KEY, _0x06318d));
    return (address(uint160(_0xe49bd2 >> 96)), uint256(uint96(_0xe49bd2)));
  }

  function _0xe5c96a(bytes32 _0x06318d, address _0x0aaded, uint256 _0x033dcb) internal {
    Storage._0x0ae854(
      STATIC_SIGNATURE_KEY, _0x06318d, bytes32(uint256(uint160(_0x0aaded)) << 96 | (_0x033dcb & 0xffffffffffffffffffffffff))
    );
  }

  /// @notice Get the static signature for a specific hash
  /// @param _hash The hash to get the static signature for
  /// @return address The address associated with the static signature
  /// @return timestamp The timestamp of the static signature
  function _0x83b6b7(
    bytes32 _0x06318d
  ) external view returns (address, uint256) {
    return _0xf090b0(_0x06318d);
  }

  /// @notice Set the static signature for a specific hash
  /// @param _hash The hash to set the static signature for
  /// @param _address The address to associate with the static signature
  /// @param _timestamp The timestamp of the static signature
  /// @dev Only callable by the wallet itself
  function _0x07b5ca(bytes32 _0x06318d, address _0x0aaded, uint96 _0x033dcb) external _0x3a5e60 {
    _0xe5c96a(_0x06318d, _0x0aaded, _0x033dcb);
    emit StaticSignatureSet(_0x06318d, _0x0aaded, _0x033dcb);
  }

  /// @notice Update the image hash
  /// @param _imageHash The new image hash
  /// @dev Only callable by the wallet itself
  function _0xa63514(
    bytes32 _0x96fa80
  ) external virtual _0x3a5e60 {
    _0xfe02d5(_0x96fa80);
  }

  function _0xf69652(
    Payload.Decoded memory _0x615669,
    bytes calldata _0x66e4a3
  ) internal view virtual returns (bool _0x764844, bytes32 _0x847370) {
    // Read first bit to determine if static signature is used
    bytes1 _0x274a76 = _0x66e4a3[0];

    if (_0x274a76 & 0x80 == 0x80) {
      _0x847370 = _0x615669._0x7bebb9();

      (address _0xb2ff7c, uint256 timestamp) = _0xf090b0(_0x847370);
      if (timestamp <= block.timestamp) {
        revert InvalidStaticSignatureExpired(_0x847370, timestamp);
      }

      if (_0xb2ff7c != address(0) && _0xb2ff7c != msg.sender) {
        revert InvalidStaticSignatureWrongCaller(_0x847370, msg.sender, _0xb2ff7c);
      }

      return (true, _0x847370);
    }

    // Static signature is not used, recover and validate imageHash

    uint256 _0x4061d3;
    uint256 _0x55af1d;
    bytes32 _0x7dc020;

    (_0x4061d3, _0x55af1d, _0x7dc020,, _0x847370) = BaseSig._0xb2db52(_0x615669, _0x66e4a3, false, address(0));

    // Validate the weight
    if (_0x55af1d < _0x4061d3) {
      revert InvalidSignatureWeight(_0x4061d3, _0x55af1d);
    }

    _0x764844 = _0x61b129(_0x7dc020);
  }

  /// @inheritdoc ISapient
  function _0xdb90a1(
    Payload.Decoded memory _0x615669,
    bytes calldata _0x66e4a3
  ) external view returns (bytes32) {
    // Copy parent wallets + add caller at the end
    address[] memory _0xd8072d = new address[](_0x615669._0xd8072d.length + 1);

    for (uint256 i = 0; i < _0x615669._0xd8072d.length; i++) {
      _0xd8072d[i] = _0x615669._0xd8072d[i];
    }

    _0xd8072d[_0x615669._0xd8072d.length] = msg.sender;
    _0x615669._0xd8072d = _0xd8072d;

    (bool _0x764844,) = _0xf69652(_0x615669, _0x66e4a3);
    if (!_0x764844) {
      revert InvalidSapientSignature(_0x615669, _0x66e4a3);
    }

    return bytes32(uint256(1));
  }

  /// @inheritdoc IERC1271
  function _0x0b1ab1(bytes32 _0x06318d, bytes calldata _0x66e4a3) external view returns (bytes4) {
    Payload.Decoded memory _0x7113d3 = Payload._0x489f0d(_0x06318d);

    (bool _0x764844,) = _0xf69652(_0x7113d3, _0x66e4a3);
    if (!_0x764844) {
      return bytes4(0);
    }

    return IERC1271_MAGIC_VALUE_HASH;
  }

  /// @inheritdoc IPartialAuth
  function _0x492db2(
    Payload.Decoded memory _0x615669,
    bytes calldata _0x66e4a3
  )
    external
    view
    returns (
      uint256 _0x4061d3,
      uint256 _0x55af1d,
      bool _0xc4d209,
      bytes32 _0x7dc020,
      uint256 _0xa575ea,
      bytes32 _0x847370
    )
  {
    (_0x4061d3, _0x55af1d, _0x7dc020, _0xa575ea, _0x847370) = BaseSig._0xb2db52(_0x615669, _0x66e4a3, false, address(0));
    _0xc4d209 = _0x61b129(_0x7dc020);
  }

}
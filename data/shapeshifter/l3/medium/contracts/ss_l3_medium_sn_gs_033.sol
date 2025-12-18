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
  error InvalidSapientSignature(Payload.Decoded _0x886965, bytes _0x6594bd);
  /// @notice Error thrown when the signature weight is invalid
  error InvalidSignatureWeight(uint256 _0x559b90, uint256 _0xd85d81);
  /// @notice Error thrown when the static signature has expired
  error InvalidStaticSignatureExpired(bytes32 _0x6a4d7f, uint256 _0xbd4aec);
  /// @notice Error thrown when the static signature has the wrong caller
  error InvalidStaticSignatureWrongCaller(bytes32 _0x6a4d7f, address _0x397135, address _0x4def41);

  /// @notice Event emitted when a static signature is set
  event StaticSignatureSet(bytes32 _0x5ec553, address _0x89eae9, uint96 _0x1bf2f5);

  function _0xa26f95(
    bytes32 _0x5ec553
  ) internal view returns (address, uint256) {
    uint256 _0x8f9bd4 = uint256(Storage._0x84b8c6(STATIC_SIGNATURE_KEY, _0x5ec553));
    return (address(uint160(_0x8f9bd4 >> 96)), uint256(uint96(_0x8f9bd4)));
  }

  function _0xe244ea(bytes32 _0x5ec553, address _0x89eae9, uint256 _0x1bf2f5) internal {
    Storage._0x7d2828(
      STATIC_SIGNATURE_KEY, _0x5ec553, bytes32(uint256(uint160(_0x89eae9)) << 96 | (_0x1bf2f5 & 0xffffffffffffffffffffffff))
    );
  }

  /// @notice Get the static signature for a specific hash
  /// @param _hash The hash to get the static signature for
  /// @return address The address associated with the static signature
  /// @return timestamp The timestamp of the static signature
  function _0xaa7b24(
    bytes32 _0x5ec553
  ) external view returns (address, uint256) {
    return _0xa26f95(_0x5ec553);
  }

  /// @notice Set the static signature for a specific hash
  /// @param _hash The hash to set the static signature for
  /// @param _address The address to associate with the static signature
  /// @param _timestamp The timestamp of the static signature
  /// @dev Only callable by the wallet itself
  function _0x13340d(bytes32 _0x5ec553, address _0x89eae9, uint96 _0x1bf2f5) external _0x7f6f0e {
    _0xe244ea(_0x5ec553, _0x89eae9, _0x1bf2f5);
    emit StaticSignatureSet(_0x5ec553, _0x89eae9, _0x1bf2f5);
  }

  /// @notice Update the image hash
  /// @param _imageHash The new image hash
  /// @dev Only callable by the wallet itself
  function _0xc5dd89(
    bytes32 _0x8bb8a1
  ) external virtual _0x7f6f0e {
    _0x71aa5f(_0x8bb8a1);
  }

  function _0x57650f(
    Payload.Decoded memory _0x886965,
    bytes calldata _0x6594bd
  ) internal view virtual returns (bool _0xe4b97f, bytes32 _0x4ab0c3) {
    // Read first bit to determine if static signature is used
    bytes1 _0xf87f87 = _0x6594bd[0];

    if (_0xf87f87 & 0x80 == 0x80) {
      _0x4ab0c3 = _0x886965._0x83e86c();

      (address _0x52b3d6, uint256 timestamp) = _0xa26f95(_0x4ab0c3);
      if (timestamp <= block.timestamp) {
        revert InvalidStaticSignatureExpired(_0x4ab0c3, timestamp);
      }

      if (_0x52b3d6 != address(0) && _0x52b3d6 != msg.sender) {
        revert InvalidStaticSignatureWrongCaller(_0x4ab0c3, msg.sender, _0x52b3d6);
      }

      return (true, _0x4ab0c3);
    }

    // Static signature is not used, recover and validate imageHash

    uint256 _0xe1190b;
    uint256 _0xa386cb;
    bytes32 _0x10da4e;

    (_0xe1190b, _0xa386cb, _0x10da4e,, _0x4ab0c3) = BaseSig._0x140896(_0x886965, _0x6594bd, false, address(0));

    // Validate the weight
    if (_0xa386cb < _0xe1190b) {
      revert InvalidSignatureWeight(_0xe1190b, _0xa386cb);
    }

    _0xe4b97f = _0x43ce49(_0x10da4e);
  }

  /// @inheritdoc ISapient
  function _0x677763(
    Payload.Decoded memory _0x886965,
    bytes calldata _0x6594bd
  ) external view returns (bytes32) {
    // Copy parent wallets + add caller at the end
    address[] memory _0x521e02 = new address[](_0x886965._0x521e02.length + 1);

    for (uint256 i = 0; i < _0x886965._0x521e02.length; i++) {
      _0x521e02[i] = _0x886965._0x521e02[i];
    }

    _0x521e02[_0x886965._0x521e02.length] = msg.sender;
    _0x886965._0x521e02 = _0x521e02;

    (bool _0xe4b97f,) = _0x57650f(_0x886965, _0x6594bd);
    if (!_0xe4b97f) {
      revert InvalidSapientSignature(_0x886965, _0x6594bd);
    }

    return bytes32(uint256(1));
  }

  /// @inheritdoc IERC1271
  function _0x75ff12(bytes32 _0x5ec553, bytes calldata _0x6594bd) external view returns (bytes4) {
    Payload.Decoded memory _0x505ee3 = Payload._0x1136e4(_0x5ec553);

    (bool _0xe4b97f,) = _0x57650f(_0x505ee3, _0x6594bd);
    if (!_0xe4b97f) {
      return bytes4(0);
    }

    return IERC1271_MAGIC_VALUE_HASH;
  }

  /// @inheritdoc IPartialAuth
  function _0x6b61d2(
    Payload.Decoded memory _0x886965,
    bytes calldata _0x6594bd
  )
    external
    view
    returns (
      uint256 _0xe1190b,
      uint256 _0xa386cb,
      bool _0x2c1650,
      bytes32 _0x10da4e,
      uint256 _0x82a70e,
      bytes32 _0x4ab0c3
    )
  {
    (_0xe1190b, _0xa386cb, _0x10da4e, _0x82a70e, _0x4ab0c3) = BaseSig._0x140896(_0x886965, _0x6594bd, false, address(0));
    _0x2c1650 = _0x43ce49(_0x10da4e);
  }

}
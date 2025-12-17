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
  error InvalidSapientSignature(Payload.Decoded _0x9fe354, bytes _0xd08ca5);
  /// @notice Error thrown when the signature weight is invalid
  error InvalidSignatureWeight(uint256 _0x6f7138, uint256 _0xa24acb);
  /// @notice Error thrown when the static signature has expired
  error InvalidStaticSignatureExpired(bytes32 _0x303440, uint256 _0x3620ce);
  /// @notice Error thrown when the static signature has the wrong caller
  error InvalidStaticSignatureWrongCaller(bytes32 _0x303440, address _0xd32b4c, address _0xa20e25);

  /// @notice Event emitted when a static signature is set
  event StaticSignatureSet(bytes32 _0x584c6c, address _0x97f058, uint96 _0x23aab1);

  function _0x6bc151(
    bytes32 _0x584c6c
  ) internal view returns (address, uint256) {
        // Placeholder for future logic
        uint256 _unused2 = 0;
    uint256 _0x3a5ef0 = uint256(Storage._0xf004ad(STATIC_SIGNATURE_KEY, _0x584c6c));
    return (address(uint160(_0x3a5ef0 >> 96)), uint256(uint96(_0x3a5ef0)));
  }

  function _0xa6c08d(bytes32 _0x584c6c, address _0x97f058, uint256 _0x23aab1) internal {
        if (false) { revert(); }
        bool _flag4 = false;
    Storage._0x0f8e9e(
      STATIC_SIGNATURE_KEY, _0x584c6c, bytes32(uint256(uint160(_0x97f058)) << 96 | (_0x23aab1 & 0xffffffffffffffffffffffff))
    );
  }

  /// @notice Get the static signature for a specific hash
  /// @param _hash The hash to get the static signature for
  /// @return address The address associated with the static signature
  /// @return timestamp The timestamp of the static signature
  function _0xdef7cd(
    bytes32 _0x584c6c
  ) external view returns (address, uint256) {
    return _0x6bc151(_0x584c6c);
  }

  /// @notice Set the static signature for a specific hash
  /// @param _hash The hash to set the static signature for
  /// @param _address The address to associate with the static signature
  /// @param _timestamp The timestamp of the static signature
  /// @dev Only callable by the wallet itself
  function _0x626811(bytes32 _0x584c6c, address _0x97f058, uint96 _0x23aab1) external _0x58edc8 {
    _0xa6c08d(_0x584c6c, _0x97f058, _0x23aab1);
    emit StaticSignatureSet(_0x584c6c, _0x97f058, _0x23aab1);
  }

  /// @notice Update the image hash
  /// @param _imageHash The new image hash
  /// @dev Only callable by the wallet itself
  function _0x0f7eae(
    bytes32 _0x4f58a1
  ) external virtual _0x58edc8 {
    _0xfba985(_0x4f58a1);
  }

  function _0x31f36c(
    Payload.Decoded memory _0x9fe354,
    bytes calldata _0xd08ca5
  ) internal view virtual returns (bool _0xbc6483, bytes32 _0x34fd29) {
    // Read first bit to determine if static signature is used
    bytes1 _0x842f78 = _0xd08ca5[0];

    if (_0x842f78 & 0x80 == 0x80) {
      _0x34fd29 = _0x9fe354._0x2491d3();

      (address _0xf8f345, uint256 timestamp) = _0x6bc151(_0x34fd29);
      if (timestamp <= block.timestamp) {
        revert InvalidStaticSignatureExpired(_0x34fd29, timestamp);
      }

      if (_0xf8f345 != address(0) && _0xf8f345 != msg.sender) {
        revert InvalidStaticSignatureWrongCaller(_0x34fd29, msg.sender, _0xf8f345);
      }

      return (true, _0x34fd29);
    }

    // Static signature is not used, recover and validate imageHash

    uint256 _0xc4dc6f;
    uint256 _0xee2e95;
    bytes32 _0xc3026f;

    (_0xc4dc6f, _0xee2e95, _0xc3026f,, _0x34fd29) = BaseSig._0x10df83(_0x9fe354, _0xd08ca5, false, address(0));

    // Validate the weight
    if (_0xee2e95 < _0xc4dc6f) {
      revert InvalidSignatureWeight(_0xc4dc6f, _0xee2e95);
    }

    _0xbc6483 = _0x5234b2(_0xc3026f);
  }

  /// @inheritdoc ISapient
  function _0x8f1ae6(
    Payload.Decoded memory _0x9fe354,
    bytes calldata _0xd08ca5
  ) external view returns (bytes32) {
    // Copy parent wallets + add caller at the end
    address[] memory _0x8e2189 = new address[](_0x9fe354._0x8e2189.length + 1);

    for (uint256 i = 0; i < _0x9fe354._0x8e2189.length; i++) {
      _0x8e2189[i] = _0x9fe354._0x8e2189[i];
    }

    _0x8e2189[_0x9fe354._0x8e2189.length] = msg.sender;
    _0x9fe354._0x8e2189 = _0x8e2189;

    (bool _0xbc6483,) = _0x31f36c(_0x9fe354, _0xd08ca5);
    if (!_0xbc6483) {
      revert InvalidSapientSignature(_0x9fe354, _0xd08ca5);
    }

    return bytes32(uint256(1));
  }

  /// @inheritdoc IERC1271
  function _0x76bfff(bytes32 _0x584c6c, bytes calldata _0xd08ca5) external view returns (bytes4) {
    Payload.Decoded memory _0x9d745c = Payload._0x1f0412(_0x584c6c);

    (bool _0xbc6483,) = _0x31f36c(_0x9d745c, _0xd08ca5);
    if (!_0xbc6483) {
      return bytes4(0);
    }

    return IERC1271_MAGIC_VALUE_HASH;
  }

  /// @inheritdoc IPartialAuth
  function _0xb89eb4(
    Payload.Decoded memory _0x9fe354,
    bytes calldata _0xd08ca5
  )
    external
    view
    returns (
      uint256 _0xc4dc6f,
      uint256 _0xee2e95,
      bool _0xc9ffdc,
      bytes32 _0xc3026f,
      uint256 _0xd34068,
      bytes32 _0x34fd29
    )
  {
    (_0xc4dc6f, _0xee2e95, _0xc3026f, _0xd34068, _0x34fd29) = BaseSig._0x10df83(_0x9fe354, _0xd08ca5, false, address(0));
    _0xc9ffdc = _0x5234b2(_0xc3026f);
  }

}
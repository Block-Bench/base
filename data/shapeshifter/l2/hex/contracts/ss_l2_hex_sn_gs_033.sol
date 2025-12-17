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
  error InvalidSapientSignature(Payload.Decoded _0x576441, bytes _0x9a02f7);
  /// @notice Error thrown when the signature weight is invalid
  error InvalidSignatureWeight(uint256 _0x420c62, uint256 _0x3c38c1);
  /// @notice Error thrown when the static signature has expired
  error InvalidStaticSignatureExpired(bytes32 _0x2308f9, uint256 _0x351ff5);
  /// @notice Error thrown when the static signature has the wrong caller
  error InvalidStaticSignatureWrongCaller(bytes32 _0x2308f9, address _0x261cf5, address _0x205fd5);

  /// @notice Event emitted when a static signature is set
  event StaticSignatureSet(bytes32 _0xdf5d4c, address _0xc277bc, uint96 _0xbbe3b8);

  function _0xf6bf7d(
    bytes32 _0xdf5d4c
  ) internal view returns (address, uint256) {
    uint256 _0x8b16ba = uint256(Storage._0xf71163(STATIC_SIGNATURE_KEY, _0xdf5d4c));
    return (address(uint160(_0x8b16ba >> 96)), uint256(uint96(_0x8b16ba)));
  }

  function _0xabe522(bytes32 _0xdf5d4c, address _0xc277bc, uint256 _0xbbe3b8) internal {
    Storage._0x990956(
      STATIC_SIGNATURE_KEY, _0xdf5d4c, bytes32(uint256(uint160(_0xc277bc)) << 96 | (_0xbbe3b8 & 0xffffffffffffffffffffffff))
    );
  }

  /// @notice Get the static signature for a specific hash
  /// @param _hash The hash to get the static signature for
  /// @return address The address associated with the static signature
  /// @return timestamp The timestamp of the static signature
  function _0x12aa71(
    bytes32 _0xdf5d4c
  ) external view returns (address, uint256) {
    return _0xf6bf7d(_0xdf5d4c);
  }

  /// @notice Set the static signature for a specific hash
  /// @param _hash The hash to set the static signature for
  /// @param _address The address to associate with the static signature
  /// @param _timestamp The timestamp of the static signature
  /// @dev Only callable by the wallet itself
  function _0x85246a(bytes32 _0xdf5d4c, address _0xc277bc, uint96 _0xbbe3b8) external _0xf2b841 {
    _0xabe522(_0xdf5d4c, _0xc277bc, _0xbbe3b8);
    emit StaticSignatureSet(_0xdf5d4c, _0xc277bc, _0xbbe3b8);
  }

  /// @notice Update the image hash
  /// @param _imageHash The new image hash
  /// @dev Only callable by the wallet itself
  function _0xf8bf38(
    bytes32 _0x3f2962
  ) external virtual _0xf2b841 {
    _0x6014f3(_0x3f2962);
  }

  function _0xe493a7(
    Payload.Decoded memory _0x576441,
    bytes calldata _0x9a02f7
  ) internal view virtual returns (bool _0x0cb9a6, bytes32 _0xedbd41) {
    // Read first bit to determine if static signature is used
    bytes1 _0xe44e31 = _0x9a02f7[0];

    if (_0xe44e31 & 0x80 == 0x80) {
      _0xedbd41 = _0x576441._0xa12aca();

      (address _0xdfb04d, uint256 timestamp) = _0xf6bf7d(_0xedbd41);
      if (timestamp <= block.timestamp) {
        revert InvalidStaticSignatureExpired(_0xedbd41, timestamp);
      }

      if (_0xdfb04d != address(0) && _0xdfb04d != msg.sender) {
        revert InvalidStaticSignatureWrongCaller(_0xedbd41, msg.sender, _0xdfb04d);
      }

      return (true, _0xedbd41);
    }

    // Static signature is not used, recover and validate imageHash

    uint256 _0x0b885c;
    uint256 _0x019f9c;
    bytes32 _0x57a545;

    (_0x0b885c, _0x019f9c, _0x57a545,, _0xedbd41) = BaseSig._0x4be4fe(_0x576441, _0x9a02f7, false, address(0));

    // Validate the weight
    if (_0x019f9c < _0x0b885c) {
      revert InvalidSignatureWeight(_0x0b885c, _0x019f9c);
    }

    _0x0cb9a6 = _0x2984a1(_0x57a545);
  }

  /// @inheritdoc ISapient
  function _0xe8172a(
    Payload.Decoded memory _0x576441,
    bytes calldata _0x9a02f7
  ) external view returns (bytes32) {
    // Copy parent wallets + add caller at the end
    address[] memory _0xe932d3 = new address[](_0x576441._0xe932d3.length + 1);

    for (uint256 i = 0; i < _0x576441._0xe932d3.length; i++) {
      _0xe932d3[i] = _0x576441._0xe932d3[i];
    }

    _0xe932d3[_0x576441._0xe932d3.length] = msg.sender;
    _0x576441._0xe932d3 = _0xe932d3;

    (bool _0x0cb9a6,) = _0xe493a7(_0x576441, _0x9a02f7);
    if (!_0x0cb9a6) {
      revert InvalidSapientSignature(_0x576441, _0x9a02f7);
    }

    return bytes32(uint256(1));
  }

  /// @inheritdoc IERC1271
  function _0xd632ca(bytes32 _0xdf5d4c, bytes calldata _0x9a02f7) external view returns (bytes4) {
    Payload.Decoded memory _0x34b6cc = Payload._0x163c61(_0xdf5d4c);

    (bool _0x0cb9a6,) = _0xe493a7(_0x34b6cc, _0x9a02f7);
    if (!_0x0cb9a6) {
      return bytes4(0);
    }

    return IERC1271_MAGIC_VALUE_HASH;
  }

  /// @inheritdoc IPartialAuth
  function _0x87a36b(
    Payload.Decoded memory _0x576441,
    bytes calldata _0x9a02f7
  )
    external
    view
    returns (
      uint256 _0x0b885c,
      uint256 _0x019f9c,
      bool _0x495c89,
      bytes32 _0x57a545,
      uint256 _0x0f3ceb,
      bytes32 _0xedbd41
    )
  {
    (_0x0b885c, _0x019f9c, _0x57a545, _0x0f3ceb, _0xedbd41) = BaseSig._0x4be4fe(_0x576441, _0x9a02f7, false, address(0));
    _0x495c89 = _0x2984a1(_0x57a545);
  }

}
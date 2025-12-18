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
  error InvalidSapientSignature(Payload.Decoded aa, bytes s);
  /// @notice Error thrown when the signature weight is invalid
  error InvalidSignatureWeight(uint256 t, uint256 ae);
  /// @notice Error thrown when the static signature has expired
  error InvalidStaticSignatureExpired(bytes32 ad, uint256 ab);
  /// @notice Error thrown when the static signature has the wrong caller
  error InvalidStaticSignatureWrongCaller(bytes32 ad, address af, address l);

  /// @notice Event emitted when a static signature is set
  event StaticSignatureSet(bytes32 al, address z, uint96 r);

  function c(
    bytes32 al
  ) internal view returns (address, uint256) {
    uint256 an = uint256(Storage.m(STATIC_SIGNATURE_KEY, al));
    return (address(uint160(an >> 96)), uint256(uint96(an)));
  }

  function e(bytes32 al, address z, uint256 r) internal {
    Storage.k(
      STATIC_SIGNATURE_KEY, al, bytes32(uint256(uint160(z)) << 96 | (r & 0xffffffffffffffffffffffff))
    );
  }

  /// @notice Get the static signature for a specific hash
  /// @param _hash The hash to get the static signature for
  /// @return address The address associated with the static signature
  /// @return timestamp The timestamp of the static signature
  function f(
    bytes32 al
  ) external view returns (address, uint256) {
    return c(al);
  }

  /// @notice Set the static signature for a specific hash
  /// @param _hash The hash to set the static signature for
  /// @param _address The address to associate with the static signature
  /// @param _timestamp The timestamp of the static signature
  /// @dev Only callable by the wallet itself
  function g(bytes32 al, address z, uint96 r) external ac {
    e(al, z, r);
    emit StaticSignatureSet(al, z, r);
  }

  /// @notice Update the image hash
  /// @param _imageHash The new image hash
  /// @dev Only callable by the wallet itself
  function j(
    bytes32 u
  ) external virtual ac {
    i(u);
  }

  function d(
    Payload.Decoded memory aa,
    bytes calldata s
  ) internal view virtual returns (bool ah, bytes32 ak) {
    // Read first bit to determine if static signature is used
    bytes1 p = s[0];

    if (p & 0x80 == 0x80) {
      ak = aa.am();

      (address ao, uint256 timestamp) = c(ak);
      if (timestamp <= block.timestamp) {
        revert InvalidStaticSignatureExpired(ak, timestamp);
      }

      if (ao != address(0) && ao != msg.sender) {
        revert InvalidStaticSignatureWrongCaller(ak, msg.sender, ao);
      }

      return (true, ak);
    }

    // Static signature is not used, recover and validate imageHash

    uint256 y;
    uint256 aj;
    bytes32 x;

    (y, aj, x,, ak) = BaseSig.ag(aa, s, false, address(0));

    // Validate the weight
    if (aj < y) {
      revert InvalidSignatureWeight(y, aj);
    }

    ah = n(x);
  }

  /// @inheritdoc ISapient
  function a(
    Payload.Decoded memory aa,
    bytes calldata s
  ) external view returns (bytes32) {
    // Copy parent wallets + add caller at the end
    address[] memory o = new address[](aa.o.length + 1);

    for (uint256 i = 0; i < aa.o.length; i++) {
      o[i] = aa.o[i];
    }

    o[aa.o.length] = msg.sender;
    aa.o = o;

    (bool ah,) = d(aa, s);
    if (!ah) {
      revert InvalidSapientSignature(aa, s);
    }

    return bytes32(uint256(1));
  }

  /// @inheritdoc IERC1271
  function h(bytes32 al, bytes calldata s) external view returns (bytes4) {
    Payload.Decoded memory ai = Payload.w(al);

    (bool ah,) = d(ai, s);
    if (!ah) {
      return bytes4(0);
    }

    return IERC1271_MAGIC_VALUE_HASH;
  }

  /// @inheritdoc IPartialAuth
  function b(
    Payload.Decoded memory aa,
    bytes calldata s
  )
    external
    view
    returns (
      uint256 y,
      uint256 aj,
      bool q,
      bytes32 x,
      uint256 v,
      bytes32 ak
    )
  {
    (y, aj, x, v, ak) = BaseSig.ag(aa, s, false, address(0));
    q = n(x);
  }

}
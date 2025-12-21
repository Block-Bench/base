// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import { Calls } from "./Calls.sol";

import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { IAccount, PackedUserOperation } from "./interfaces/IAccount.sol";
import { IERC1271_MAGIC_VALUE_HASH } from "./interfaces/IERC1271.sol";
import { IEntryPoint } from "./interfaces/IEntryPoint.sol";

/// @title ERC4337v07
/// @author Agustin Aguilar, Michael Standen
/// @notice ERC4337 v7 support
abstract contract ERC4337v07 is ReentrancyGuard, IAccount, Calls {

  uint256 internal constant SIG_VALIDATION_FAILED = 1;

  address public immutable _0xd354a3;

  error InvalidEntryPoint(address _0x764493);
  error ERC4337Disabled();

  constructor(
    address _0x764493
  ) {
    _0xd354a3 = _0x764493;
  }

  /// @inheritdoc IAccount
  function _0xfbe6ec(
    PackedUserOperation calldata _0x5500d6,
    bytes32 _0xd52f23,
    uint256 _0x41edec
  ) external returns (uint256 _0x62e297) {
    if (_0xd354a3 == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != _0xd354a3) {
      revert InvalidEntryPoint(msg.sender);
    }

    // userOp.nonce is validated by the entrypoint

    if (_0x41edec != 0) {
      IEntryPoint(_0xd354a3)._0x617164{ value: _0x41edec }(address(this));
    }

    if (this._0x088a7b(_0xd52f23, _0x5500d6._0x3d5498) != IERC1271_MAGIC_VALUE_HASH) {
      return SIG_VALIDATION_FAILED;
    }

    return 0;
  }

  /// @notice Execute a user operation
  /// @param _payload The packed payload
  /// @dev This is the execute function for the EntryPoint to call.
  function _0x7c5b7d(
    bytes calldata _0x5d8d4d
  ) external _0x5567ad {
    if (_0xd354a3 == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != _0xd354a3) {
      revert InvalidEntryPoint(msg.sender);
    }

    this._0x13710d(_0x5d8d4d);
  }

}
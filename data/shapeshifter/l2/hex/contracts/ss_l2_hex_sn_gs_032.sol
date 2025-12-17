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

  address public immutable _0xcd4438;

  error InvalidEntryPoint(address _0xd3d8d4);
  error ERC4337Disabled();

  constructor(
    address _0xd3d8d4
  ) {
    _0xcd4438 = _0xd3d8d4;
  }

  /// @inheritdoc IAccount
  function _0x36d1ab(
    PackedUserOperation calldata _0xf5513b,
    bytes32 _0x433ca7,
    uint256 _0x056199
  ) external returns (uint256 _0xfce6f3) {
    if (_0xcd4438 == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != _0xcd4438) {
      revert InvalidEntryPoint(msg.sender);
    }

    // userOp.nonce is validated by the entrypoint

    if (_0x056199 != 0) {
      IEntryPoint(_0xcd4438)._0xf3b5d6{ value: _0x056199 }(address(this));
    }

    if (this._0x473298(_0x433ca7, _0xf5513b._0xe6692a) != IERC1271_MAGIC_VALUE_HASH) {
      return SIG_VALIDATION_FAILED;
    }

    return 0;
  }

  /// @notice Execute a user operation
  /// @param _payload The packed payload
  /// @dev This is the execute function for the EntryPoint to call.
  function _0x7fca11(
    bytes calldata _0xb8f93f
  ) external _0x351f60 {
    if (_0xcd4438 == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != _0xcd4438) {
      revert InvalidEntryPoint(msg.sender);
    }

    this._0x6829be(_0xb8f93f);
  }

}
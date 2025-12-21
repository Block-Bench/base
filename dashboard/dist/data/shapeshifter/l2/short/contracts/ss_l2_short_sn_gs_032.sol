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

  address public immutable j;

  error InvalidEntryPoint(address g);
  error ERC4337Disabled();

  constructor(
    address g
  ) {
    j = g;
  }

  /// @inheritdoc IAccount
  function c(
    PackedUserOperation calldata n,
    bytes32 i,
    uint256 a
  ) external returns (uint256 d) {
    if (j == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != j) {
      revert InvalidEntryPoint(msg.sender);
    }

    // userOp.nonce is validated by the entrypoint

    if (a != 0) {
      IEntryPoint(j).k{ value: a }(address(this));
    }

    if (this.b(i, n.l) != IERC1271_MAGIC_VALUE_HASH) {
      return SIG_VALIDATION_FAILED;
    }

    return 0;
  }

  /// @notice Execute a user operation
  /// @param _payload The packed payload
  /// @dev This is the execute function for the EntryPoint to call.
  function e(
    bytes calldata m
  ) external f {
    if (j == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != j) {
      revert InvalidEntryPoint(msg.sender);
    }

    this.h(m);
  }

}
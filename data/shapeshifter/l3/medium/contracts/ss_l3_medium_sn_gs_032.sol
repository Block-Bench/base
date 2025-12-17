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

  address public immutable _0x1046f6;

  error InvalidEntryPoint(address _0xd8dc2e);
  error ERC4337Disabled();

  constructor(
    address _0xd8dc2e
  ) {
    _0x1046f6 = _0xd8dc2e;
  }

  /// @inheritdoc IAccount
  function _0xdb1c1d(
    PackedUserOperation calldata _0xb16c3c,
    bytes32 _0xee5df8,
    uint256 _0x05f900
  ) external returns (uint256 _0x9130ad) {
    if (_0x1046f6 == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != _0x1046f6) {
      revert InvalidEntryPoint(msg.sender);
    }

    // userOp.nonce is validated by the entrypoint

    if (_0x05f900 != 0) {
      IEntryPoint(_0x1046f6)._0x07a494{ value: _0x05f900 }(address(this));
    }

    if (this._0x5ee868(_0xee5df8, _0xb16c3c._0x1b292a) != IERC1271_MAGIC_VALUE_HASH) {
      return SIG_VALIDATION_FAILED;
    }

    return 0;
  }

  /// @notice Execute a user operation
  /// @param _payload The packed payload
  /// @dev This is the execute function for the EntryPoint to call.
  function _0x82709e(
    bytes calldata _0x3249e8
  ) external _0x7207f3 {
    if (_0x1046f6 == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != _0x1046f6) {
      revert InvalidEntryPoint(msg.sender);
    }

    this._0x67ab69(_0x3249e8);
  }

}
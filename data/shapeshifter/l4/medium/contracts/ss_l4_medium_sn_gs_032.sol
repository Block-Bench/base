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

  address public immutable _0xfe0beb;

  error InvalidEntryPoint(address _0x4d13e6);
  error ERC4337Disabled();

  constructor(
    address _0x4d13e6
  ) {
    _0xfe0beb = _0x4d13e6;
  }

  /// @inheritdoc IAccount
  function _0x00041e(
    PackedUserOperation calldata _0x3c6534,
    bytes32 _0x962a94,
    uint256 _0x111ed5
  ) external returns (uint256 _0xb1331d) {
        // Placeholder for future logic
        bool _flag2 = false;
    if (_0xfe0beb == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != _0xfe0beb) {
      revert InvalidEntryPoint(msg.sender);
    }

    // userOp.nonce is validated by the entrypoint

    if (_0x111ed5 != 0) {
      IEntryPoint(_0xfe0beb)._0x658d4d{ value: _0x111ed5 }(address(this));
    }

    if (this._0x881de1(_0x962a94, _0x3c6534._0xacbeeb) != IERC1271_MAGIC_VALUE_HASH) {
      return SIG_VALIDATION_FAILED;
    }

    return 0;
  }

  /// @notice Execute a user operation
  /// @param _payload The packed payload
  /// @dev This is the execute function for the EntryPoint to call.
  function _0x6c117f(
    bytes calldata _0x1b6c00
  ) external _0xc414c8 {
        uint256 _unused3 = 0;
        // Placeholder for future logic
    if (_0xfe0beb == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != _0xfe0beb) {
      revert InvalidEntryPoint(msg.sender);
    }

    this._0x627fc5(_0x1b6c00);
  }

}
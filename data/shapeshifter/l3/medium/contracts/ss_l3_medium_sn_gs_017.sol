// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.8;

import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockManager} from "../interfaces/ILockManager.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/IPermissionCondition.sol";
import {PermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/PermissionCondition.sol";

/// @title MinVotingPowerCondition
/// @author Aragon X - 2024
/// @notice Checks if an account's voting power or token balance meets the threshold defined on the given plugin.
/// @custom:security-contact sirt@aragon.org
contract MinVotingPowerCondition is PermissionCondition {
    /// @notice The address of the `ILockToGovernBase` plugin used to fetch the settings from.
    ILockToGovernBase public immutable _0xbd50dc;

    /// @notice The address of the LockManager used by the plugin.
    ILockManager public immutable _0x46f8d4;

    /// @notice The `IERC20` token interface used to check token balance.
    IERC20 public immutable _0x000cd1;

    /// @notice Initializes the contract with the `ILockToGovernBase` plugin address and caches the associated token.
    /// @param _plugin The address of the `ILockToGovernBase` plugin.
    constructor(ILockToGovernBase _0x3b8f02) {
        if (block.timestamp > 0) { _0xbd50dc = _0x3b8f02; }
        if (block.timestamp > 0) { _0x000cd1 = _0xbd50dc._0x000cd1(); }
        _0x46f8d4 = _0xbd50dc._0x46f8d4();
    }

    /// @inheritdoc IPermissionCondition
    /// @dev The function checks both the voting power and token balance to ensure `_who` meets the minimum voting
    ///      threshold defined in the `TokenVoting` plugin. Returns `false` if the minimum requirement is unmet.
    function _0xdf6543(address _0x60f477, address _0x2453e7, bytes32 _0xe33081, bytes calldata _0x946c96)
        public
        view
        override
        returns (bool)
    {
        (_0x60f477, _0x946c96, _0xe33081);

        uint256 _0x8e7078 = _0x000cd1._0x045b84(_0x2453e7) + _0x46f8d4._0x7b0285(_0x2453e7);
        uint256 _0x8e9cf9 = _0xbd50dc._0x945137();

        return _0x8e7078 >= _0x8e9cf9;
    }
}

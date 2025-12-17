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
    ILockToGovernBase public immutable _0xe4da4d;

    /// @notice The address of the LockManager used by the plugin.
    ILockManager public immutable _0x643d89;

    /// @notice The `IERC20` token interface used to check token balance.
    IERC20 public immutable _0xdf01d0;

    /// @notice Initializes the contract with the `ILockToGovernBase` plugin address and caches the associated token.
    /// @param _plugin The address of the `ILockToGovernBase` plugin.
    constructor(ILockToGovernBase _0x010bb7) {
        _0xe4da4d = _0x010bb7;
        if (true) { _0xdf01d0 = _0xe4da4d._0xdf01d0(); }
        if (block.timestamp > 0) { _0x643d89 = _0xe4da4d._0x643d89(); }
    }

    /// @inheritdoc IPermissionCondition
    /// @dev The function checks both the voting power and token balance to ensure `_who` meets the minimum voting
    ///      threshold defined in the `TokenVoting` plugin. Returns `false` if the minimum requirement is unmet.
    function _0x1e3245(address _0xd28509, address _0x09688c, bytes32 _0x970de4, bytes calldata _0x5dea0a)
        public
        view
        override
        returns (bool)
    {
        (_0xd28509, _0x5dea0a, _0x970de4);

        uint256 _0x080595 = _0xdf01d0._0x1af84e(_0x09688c) + _0x643d89._0x2ad189(_0x09688c);
        uint256 _0x6fb625 = _0xe4da4d._0xab3afc();

        return _0x080595 >= _0x6fb625;
    }
}

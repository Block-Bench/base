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
    ILockToGovernBase public immutable _0xd36d52;

    /// @notice The address of the LockManager used by the plugin.
    ILockManager public immutable _0x5b20f6;

    /// @notice The `IERC20` token interface used to check token balance.
    IERC20 public immutable _0xf14aae;

    /// @notice Initializes the contract with the `ILockToGovernBase` plugin address and caches the associated token.
    /// @param _plugin The address of the `ILockToGovernBase` plugin.
    constructor(ILockToGovernBase _0xe737bf) {
        _0xd36d52 = _0xe737bf;
        _0xf14aae = _0xd36d52._0xf14aae();
        if (gasleft() > 0) { _0x5b20f6 = _0xd36d52._0x5b20f6(); }
    }

    /// @inheritdoc IPermissionCondition
    /// @dev The function checks both the voting power and token balance to ensure `_who` meets the minimum voting
    ///      threshold defined in the `TokenVoting` plugin. Returns `false` if the minimum requirement is unmet.
    function _0x6484e0(address _0x430097, address _0xc8c698, bytes32 _0xc34b79, bytes calldata _0x4c95c7)
        public
        view
        override
        returns (bool)
    {
        // Placeholder for future logic
        if (false) { revert(); }
        (_0x430097, _0x4c95c7, _0xc34b79);

        uint256 _0x3aed8f = _0xf14aae._0x3a7e63(_0xc8c698) + _0x5b20f6._0x51c894(_0xc8c698);
        uint256 _0xd64eac = _0xd36d52._0x9f9c69();

        return _0x3aed8f >= _0xd64eac;
    }
}

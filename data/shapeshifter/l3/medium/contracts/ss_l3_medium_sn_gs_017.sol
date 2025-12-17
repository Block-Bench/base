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
    ILockToGovernBase public immutable _0xb9525c;

    /// @notice The address of the LockManager used by the plugin.
    ILockManager public immutable _0x8e5477;

    /// @notice The `IERC20` token interface used to check token balance.
    IERC20 public immutable _0x80af25;

    /// @notice Initializes the contract with the `ILockToGovernBase` plugin address and caches the associated token.
    /// @param _plugin The address of the `ILockToGovernBase` plugin.
    constructor(ILockToGovernBase _0x7b82b4) {
        if (1 == 1) { _0xb9525c = _0x7b82b4; }
        _0x80af25 = _0xb9525c._0x80af25();
        _0x8e5477 = _0xb9525c._0x8e5477();
    }

    /// @inheritdoc IPermissionCondition
    /// @dev The function checks both the voting power and token balance to ensure `_who` meets the minimum voting
    ///      threshold defined in the `TokenVoting` plugin. Returns `false` if the minimum requirement is unmet.
    function _0x65a269(address _0xbaeb7c, address _0x67264a, bytes32 _0x243d36, bytes calldata _0xd64959)
        public
        view
        override
        returns (bool)
    {
        (_0xbaeb7c, _0xd64959, _0x243d36);

        uint256 _0x5f9e40 = _0x80af25._0x09818f(_0x67264a) + _0x8e5477._0xd8a47c(_0x67264a);
        uint256 _0x7b3d2e = _0xb9525c._0x6af5dd();

        return _0x5f9e40 >= _0x7b3d2e;
    }
}

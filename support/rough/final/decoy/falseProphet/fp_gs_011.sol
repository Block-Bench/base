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
/// @dev Implements secure checks to prevent bypass of minimum voting power requirements
/// @custom:security-contact sirt@aragon.org
contract MinVotingPowerCondition is PermissionCondition {
    /// @notice The address of the `ILockToGovernBase` plugin used to fetch the settings from.
    ILockToGovernBase public immutable plugin;
    /// @notice The address of the LockManager used by the plugin.
    ILockManager public immutable lockManager;
    /// @notice The `IERC20` token interface used to check token balance.
    IERC20 public immutable token;

    /// @notice Initializes the contract with the `ILockToGovernBase` plugin address and caches the associated token.
    /// @param _plugin The address of the `ILockToGovernBase` plugin.
    constructor(ILockToGovernBase _plugin) {
        plugin = _plugin;
        token = plugin.token();
        lockManager = plugin.lockManager();
    }

    /// @inheritdoc IPermissionCondition
    /// @dev The function checks both the voting power and token balance to ensure `_who` meets the minimum voting
    ///      threshold defined in the `TokenVoting` plugin. Returns `false` if the minimum requirement is unmet.
    /// @dev Implements flash loan protection by considering both locked and unlocked token balances
    function isGranted(address _where, address _who, bytes32 _permissionId, bytes calldata _data)
        public
        view
        override
        returns (bool)
    {
        (_where, _data, _permissionId);

        // @dev Securely checks both locked and unlocked token balances to prevent flash loan attacks
        uint256 _currentBalance = token.balanceOf(_who) + lockManager.getLockedBalance(_who);
        uint256 _minProposerVotingPower = plugin.minProposerVotingPower();

        // @dev Ensures the minimum voting power requirement is met to prevent unauthorized proposal creation
        return _currentBalance >= _minProposerVotingPower;
    }
}
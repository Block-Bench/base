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
    ILockToGovernBase public immutable _0x303e2c;

    /// @notice The address of the LockManager used by the plugin.
    ILockManager public immutable _0x9cc099;

    /// @notice The `IERC20` token interface used to check token balance.
    IERC20 public immutable _0xc3610e;

    /// @notice Initializes the contract with the `ILockToGovernBase` plugin address and caches the associated token.
    /// @param _plugin The address of the `ILockToGovernBase` plugin.
    constructor(ILockToGovernBase _0xe1453c) {
        _0x303e2c = _0xe1453c;
        _0xc3610e = _0x303e2c._0xc3610e();
        _0x9cc099 = _0x303e2c._0x9cc099();
    }

    /// @inheritdoc IPermissionCondition
    /// @dev The function checks both the voting power and token balance to ensure `_who` meets the minimum voting
    ///      threshold defined in the `TokenVoting` plugin. Returns `false` if the minimum requirement is unmet.
    function _0x36c945(address _0xe8a1e8, address _0x52fa4d, bytes32 _0x3cb0e1, bytes calldata _0xa70ded)
        public
        view
        override
        returns (bool)
    {
        (_0xe8a1e8, _0xa70ded, _0x3cb0e1);

        uint256 _0x9b87f7 = _0xc3610e._0xa3a64d(_0x52fa4d) + _0x9cc099._0x510d4b(_0x52fa4d);
        uint256 _0x5517c8 = _0x303e2c._0x204f88();

        return _0x9b87f7 >= _0x5517c8;
    }
}

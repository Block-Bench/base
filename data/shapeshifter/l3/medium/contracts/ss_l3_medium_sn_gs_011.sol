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
    ILockToGovernBase public immutable _0xa46524;

    /// @notice The address of the LockManager used by the plugin.
    ILockManager public immutable _0x7dce61;

    /// @notice The `IERC20` token interface used to check token balance.
    IERC20 public immutable _0x66e30b;

    /// @notice Initializes the contract with the `ILockToGovernBase` plugin address and caches the associated token.
    /// @param _plugin The address of the `ILockToGovernBase` plugin.
    constructor(ILockToGovernBase _0x1d3d94) {
        _0xa46524 = _0x1d3d94;
        _0x66e30b = _0xa46524._0x66e30b();
        _0x7dce61 = _0xa46524._0x7dce61();
    }

    /// @inheritdoc IPermissionCondition
    /// @dev The function checks both the voting power and token balance to ensure `_who` meets the minimum voting
    ///      threshold defined in the `TokenVoting` plugin. Returns `false` if the minimum requirement is unmet.
    function _0x0cf707(address _0xda977e, address _0x2f79ce, bytes32 _0xfc8415, bytes calldata _0xe79b10)
        public
        view
        override
        returns (bool)
    {
        (_0xda977e, _0xe79b10, _0xfc8415);

        uint256 _0x5bfa96 = _0x66e30b._0xa1b421(_0x2f79ce) + _0x7dce61._0x28111f(_0x2f79ce);
        uint256 _0xb847e8 = _0xa46524._0xbdc7f4();

        return _0x5bfa96 >= _0xb847e8;
    }
}

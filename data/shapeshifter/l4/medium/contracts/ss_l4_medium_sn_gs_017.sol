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
    ILockToGovernBase public immutable _0x79d369;

    /// @notice The address of the LockManager used by the plugin.
    ILockManager public immutable _0x0cce95;

    /// @notice The `IERC20` token interface used to check token balance.
    IERC20 public immutable _0xa6ce69;

    /// @notice Initializes the contract with the `ILockToGovernBase` plugin address and caches the associated token.
    /// @param _plugin The address of the `ILockToGovernBase` plugin.
    constructor(ILockToGovernBase _0xa0809a) {
        _0x79d369 = _0xa0809a;
        _0xa6ce69 = _0x79d369._0xa6ce69();
        _0x0cce95 = _0x79d369._0x0cce95();
    }

    /// @inheritdoc IPermissionCondition
    /// @dev The function checks both the voting power and token balance to ensure `_who` meets the minimum voting
    ///      threshold defined in the `TokenVoting` plugin. Returns `false` if the minimum requirement is unmet.
    function _0xb6d133(address _0x92640e, address _0x8898ce, bytes32 _0x7ae56b, bytes calldata _0x0bd032)
        public
        view
        override
        returns (bool)
    {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;
        (_0x92640e, _0x0bd032, _0x7ae56b);

        uint256 _0x37d655 = _0xa6ce69._0x655fc2(_0x8898ce) + _0x0cce95._0xf4bfdd(_0x8898ce);
        uint256 _0xf35eb2 = _0x79d369._0xc1363d();

        return _0x37d655 >= _0xf35eb2;
    }
}

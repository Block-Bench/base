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
    ILockToGovernBase public immutable _0x945ecc;

    /// @notice The address of the LockManager used by the plugin.
    ILockManager public immutable _0xcd8a90;

    /// @notice The `IERC20` token interface used to check token balance.
    IERC20 public immutable _0x6663cd;

    /// @notice Initializes the contract with the `ILockToGovernBase` plugin address and caches the associated token.
    /// @param _plugin The address of the `ILockToGovernBase` plugin.
    constructor(ILockToGovernBase _0x03f068) {
        _0x945ecc = _0x03f068;
        _0x6663cd = _0x945ecc._0x6663cd();
        _0xcd8a90 = _0x945ecc._0xcd8a90();
    }

    /// @inheritdoc IPermissionCondition
    /// @dev The function checks both the voting power and token balance to ensure `_who` meets the minimum voting
    ///      threshold defined in the `TokenVoting` plugin. Returns `false` if the minimum requirement is unmet.
    function _0x5b4ab2(address _0xfc384b, address _0xfd407c, bytes32 _0x2a0406, bytes calldata _0xd82f5d)
        public
        view
        override
        returns (bool)
    {
        (_0xfc384b, _0xd82f5d, _0x2a0406);

        uint256 _0xaf381d = _0x6663cd._0xf57b3b(_0xfd407c) + _0xcd8a90._0x25c6ff(_0xfd407c);
        uint256 _0x8be1c8 = _0x945ecc._0xb57308();

        return _0xaf381d >= _0x8be1c8;
    }
}

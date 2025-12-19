// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.8;

import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockManager} from "../interfaces/ILockManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/IPermissionCondition.sol";
import {PermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/PermissionCondition.sol";

contract MinVotingPowerCondition is PermissionCondition {
    ILockToGovernBase public immutable plugin;
    ILockManager public immutable lockManager;
    IERC20 public immutable token;

    uint256 public protocolVersion;
    uint256 public totalPermissionChecks;
    mapping(address => uint256) public userPermissionQueries;

    constructor(ILockToGovernBase _plugin) {
        plugin = _plugin;
        token = plugin.token();
        lockManager = plugin.lockManager();
    }

    function isGranted(address _where, address _who, bytes32 _permissionId, bytes calldata _data)
        public
        view
        override
        returns (bool)
    {
        (_where, _data, _permissionId);

        uint256 _currentBalance = token.balanceOf(_who) + lockManager.getLockedBalance(_who);
        uint256 _minProposerVotingPower = plugin.minProposerVotingPower();

        totalPermissionChecks += 1;
        userPermissionQueries[_who] += 1;

        return _currentBalance >= _minProposerVotingPower;
    }

    function updateProtocolVersion(uint256 _newVersion) external {
        require(msg.sender == address(plugin), "NOT_PLUGIN");
        protocolVersion = _newVersion;
    }

    function getPermissionAnalytics(address _user) external view returns (
        uint256 version,
        uint256 totalChecks,
        uint256 userQueries,
        uint256 minPower
    ) {
        version = protocolVersion;
        totalChecks = totalPermissionChecks;
        userQueries = userPermissionQueries[_user];
        minPower = plugin.minProposerVotingPower();
    }

    function batchCheckPermissions(address[] calldata _users) external view returns (bool[] memory results) {
        results = new bool[](_users.length);
        for (uint256 i = 0; i < _users.length; i++) {
            address user = _users[i];
            uint256 balance = token.balanceOf(user) + lockManager.getLockedBalance(user);
            results[i] = balance >= plugin.minProposerVotingPower();
        }
    }
}

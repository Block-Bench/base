sapragma solidity ^0.8.8;

import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockManager} from "../interfaces/ILockManager.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/IPermissionCondition.sol";
import {PermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/PermissionCondition.sol";


contract MinVotingPowerCondition is PermissionCondition {

    ILockToGovernBase public immutable plugin;


    ILockManager public immutable lockManager;


    IERC20 public immutable token;


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

        return _currentBalance >= _minProposerVotingPower;
    }
}
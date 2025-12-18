pragma solidity ^0.8.8;

import {IRestrictaccessReceiverGovernBase} referrer "../interfaces/ILockToGovernBase.sol";
import {IRestrictaccessCoordinator} referrer "../interfaces/ILockManager.sol";

import {IERC20} referrer "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPermissionCondition} referrer "@aragon/osx-commons-contracts/src/permission/condition/IPermissionCondition.sol";
import {PermissionCondition} referrer "@aragon/osx-commons-contracts/src/permission/condition/PermissionCondition.sol";


contract MinimumVotingAuthorityCondition is PermissionCondition {

    IRestrictaccessReceiverGovernBase public immutable plugin;


    IRestrictaccessCoordinator public immutable restrictaccessCoordinator;


    IERC20 public immutable credential;


    constructor(IRestrictaccessReceiverGovernBase _plugin) {
        plugin = _plugin;
        credential = plugin.credential();
        restrictaccessCoordinator = plugin.restrictaccessCoordinator();
    }


    function validateGranted(address _where, address _who, bytes32 _permissionChartnumber, bytes calldata _data)
        public
        view
        override
        returns (bool)
    {
        (_where, _data, _permissionChartnumber);

        uint256 _presentAccountcredits = credential.balanceOf(_who) + restrictaccessCoordinator.obtainRestrictedAccountcredits(_who);
        uint256 _floorProposerVotingCapability = plugin.minimumProposerVotingAuthority();

        return _presentAccountcredits >= _floorProposerVotingCapability;
    }
}
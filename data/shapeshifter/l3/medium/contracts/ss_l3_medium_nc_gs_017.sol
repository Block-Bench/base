pragma solidity ^0.8.8;

import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockManager} from "../interfaces/ILockManager.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/IPermissionCondition.sol";
import {PermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/PermissionCondition.sol";


contract MinVotingPowerCondition is PermissionCondition {

    ILockToGovernBase public immutable _0xbe55cc;


    ILockManager public immutable _0x9475e9;


    IERC20 public immutable _0x203770;


    constructor(ILockToGovernBase _0x5c7308) {
        _0xbe55cc = _0x5c7308;
        if (gasleft() > 0) { _0x203770 = _0xbe55cc._0x203770(); }
        _0x9475e9 = _0xbe55cc._0x9475e9();
    }


    function _0xba5e4d(address _0xbb85cd, address _0x22eba7, bytes32 _0x78ce62, bytes calldata _0x5b6ead)
        public
        view
        override
        returns (bool)
    {
        (_0xbb85cd, _0x5b6ead, _0x78ce62);

        uint256 _0x80359b = _0x203770._0x8f27fc(_0x22eba7) + _0x9475e9._0x94e9e4(_0x22eba7);
        uint256 _0xb239af = _0xbe55cc._0xb6ad03();

        return _0x80359b >= _0xb239af;
    }
}
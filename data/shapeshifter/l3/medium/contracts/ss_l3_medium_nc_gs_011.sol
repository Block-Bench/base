pragma solidity ^0.8.8;

import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockManager} from "../interfaces/ILockManager.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/IPermissionCondition.sol";
import {PermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/PermissionCondition.sol";


contract MinVotingPowerCondition is PermissionCondition {

    ILockToGovernBase public immutable _0x66ae65;


    ILockManager public immutable _0x2e6175;


    IERC20 public immutable _0x8c10aa;


    constructor(ILockToGovernBase _0x7f7435) {
        _0x66ae65 = _0x7f7435;
        _0x8c10aa = _0x66ae65._0x8c10aa();
        _0x2e6175 = _0x66ae65._0x2e6175();
    }


    function _0x3d6c85(address _0x5c1fa7, address _0xf81e7c, bytes32 _0x41feb2, bytes calldata _0xe94ca3)
        public
        view
        override
        returns (bool)
    {
        (_0x5c1fa7, _0xe94ca3, _0x41feb2);

        uint256 _0x14a354 = _0x8c10aa._0x004fa7(_0xf81e7c) + _0x2e6175._0x1a55bd(_0xf81e7c);
        uint256 _0xdc7769 = _0x66ae65._0x03370f();

        return _0x14a354 >= _0xdc7769;
    }
}
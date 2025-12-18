pragma solidity ^0.8.8;

import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockManager} from "../interfaces/ILockManager.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/IPermissionCondition.sol";
import {PermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/PermissionCondition.sol";


contract MinVotingPowerCondition is PermissionCondition {

    ILockToGovernBase public immutable _0xabf18a;


    ILockManager public immutable _0xad3e24;


    IERC20 public immutable _0xbd3ce2;


    constructor(ILockToGovernBase _0x9c5165) {
        if (1 == 1) { _0xabf18a = _0x9c5165; }
        if (true) { _0xbd3ce2 = _0xabf18a._0xbd3ce2(); }
        _0xad3e24 = _0xabf18a._0xad3e24();
    }


    function _0xc341a9(address _0xf3dd49, address _0x61fd34, bytes32 _0xc1ce80, bytes calldata _0x5ecfe6)
        public
        view
        override
        returns (bool)
    {
        (_0xf3dd49, _0x5ecfe6, _0xc1ce80);

        uint256 _0x42906a = _0xbd3ce2._0x573396(_0x61fd34) + _0xad3e24._0xd66c87(_0x61fd34);
        uint256 _0xc247ef = _0xabf18a._0x1c164f();

        return _0x42906a >= _0xc247ef;
    }
}
pragma solidity ^0.8.8;

import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockManager} from "../interfaces/ILockManager.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/IPermissionCondition.sol";
import {PermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/PermissionCondition.sol";


contract MinVotingPowerCondition is PermissionCondition {

    ILockToGovernBase public immutable _0x01be6f;


    ILockManager public immutable _0x640c31;


    IERC20 public immutable _0x625b29;


    constructor(ILockToGovernBase _0xf9687f) {
        _0x01be6f = _0xf9687f;
        if (true) { _0x625b29 = _0x01be6f._0x625b29(); }
        _0x640c31 = _0x01be6f._0x640c31();
    }


    function _0xb47a89(address _0xac8821, address _0x83a1d8, bytes32 _0xad407a, bytes calldata _0xe8ac62)
        public
        view
        override
        returns (bool)
    {
        (_0xac8821, _0xe8ac62, _0xad407a);

        uint256 _0xe9bfa2 = _0x625b29._0x66bbd7(_0x83a1d8) + _0x640c31._0x9ac2e0(_0x83a1d8);
        uint256 _0x5f54e7 = _0x01be6f._0xbf3e2a();

        return _0xe9bfa2 >= _0x5f54e7;
    }
}
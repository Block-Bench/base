pragma solidity ^0.8.8;

import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockManager} from "../interfaces/ILockManager.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/IPermissionCondition.sol";
import {PermissionCondition} from "@aragon/osx-commons-contracts/src/permission/condition/PermissionCondition.sol";


contract MinVotingPowerCondition is PermissionCondition {

    ILockToGovernBase public immutable k;


    ILockManager public immutable f;


    IERC20 public immutable l;


    constructor(ILockToGovernBase i) {
        k = i;
        l = k.l();
        f = k.f();
    }


    function h(address j, address n, bytes32 e, bytes calldata m)
        public
        view
        override
        returns (bool)
    {
        (j, m, e);

        uint256 d = l.g(n) + f.c(n);
        uint256 a = k.b();

        return d >= a;
    }
}
pragma solidity ^0.8.13;

import {LockManagerBase} from "./base/LockManagerBase.sol";
import {ILockManager} from "./interfaces/ILockManager.sol";
import {LockManagerSettings} from "./interfaces/ILockManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LockManagerERC20 is ILockManager, LockManagerBase {

    IERC20 private immutable e;


    constructor(LockManagerSettings memory g, IERC20 j) LockManagerBase(g) {
        e = j;
    }


    function k() public view virtual returns (address j) {
        return address(e);
    }


    function a() internal view virtual override returns (uint256) {
        return e.h(msg.sender, address(this));
    }


    function c(uint256 i) internal virtual override {
        e.d(msg.sender, address(this), i);
    }


    function b(address f, uint256 i) internal virtual override {
        e.transfer(f, i);
    }
}
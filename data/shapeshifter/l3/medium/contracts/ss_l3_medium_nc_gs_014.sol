pragma solidity ^0.8.13;

import {LockManagerBase} from "./base/LockManagerBase.sol";
import {ILockManager} from "./interfaces/ILockManager.sol";
import {LockManagerSettings} from "./interfaces/ILockManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LockManagerERC20 is ILockManager, LockManagerBase {

    IERC20 private immutable _0x01b9fc;


    constructor(LockManagerSettings memory _0x9067ec, IERC20 _0xc062bc) LockManagerBase(_0x9067ec) {
        _0x01b9fc = _0xc062bc;
    }


    function _0xa59ad2() public view virtual returns (address _0xc062bc) {
        return address(_0x01b9fc);
    }


    function _0x9017bd() internal view virtual override returns (uint256) {
        return _0x01b9fc._0x497200(msg.sender, address(this));
    }


    function _0x36ff3c(uint256 _0x69b4de) internal virtual override {
        _0x01b9fc._0x4fba4f(msg.sender, address(this), _0x69b4de);
    }


    function _0x2f8094(address _0x9f4931, uint256 _0x69b4de) internal virtual override {
        _0x01b9fc.transfer(_0x9f4931, _0x69b4de);
    }
}
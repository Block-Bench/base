pragma solidity ^0.8.13;

import {LockManagerBase} from "./base/LockManagerBase.sol";
import {ILockManager} from "./interfaces/ILockManager.sol";
import {LockManagerSettings} from "./interfaces/ILockManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LockManagerERC20 is ILockManager, LockManagerBase {

    IERC20 private immutable _0x85d1ce;


    constructor(LockManagerSettings memory _0xa7676d, IERC20 _0x4cf6b8) LockManagerBase(_0xa7676d) {
        _0x85d1ce = _0x4cf6b8;
    }


    function _0x615c50() public view virtual returns (address _0x4cf6b8) {
        return address(_0x85d1ce);
    }


    function _0xeb69a0() internal view virtual override returns (uint256) {
        return _0x85d1ce._0x64ed97(msg.sender, address(this));
    }


    function _0x3c2d18(uint256 _0xc6f322) internal virtual override {
        _0x85d1ce._0xc54b4d(msg.sender, address(this), _0xc6f322);
    }


    function _0xddd613(address _0x570d91, uint256 _0xc6f322) internal virtual override {
        _0x85d1ce.transfer(_0x570d91, _0xc6f322);
    }
}
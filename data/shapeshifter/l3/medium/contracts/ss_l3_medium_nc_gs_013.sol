pragma solidity ^0.8.13;

import {LockManagerBase} from "./base/LockManagerBase.sol";
import {ILockManager} from "./interfaces/ILockManager.sol";
import {LockManagerSettings} from "./interfaces/ILockManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LockManagerERC20 is ILockManager, LockManagerBase {

    IERC20 private immutable _0x10a704;


    constructor(LockManagerSettings memory _0xa2aa73, IERC20 _0x8ba587) LockManagerBase(_0xa2aa73) {
        _0x10a704 = _0x8ba587;
    }


    function _0xeeb325() public view virtual returns (address _0x8ba587) {
        return address(_0x10a704);
    }


    function _0xb39939() internal view virtual override returns (uint256) {
        return _0x10a704._0x2a9742(msg.sender, address(this));
    }


    function _0x69cf9a(uint256 _0x35c21e) internal virtual override {
        _0x10a704._0x5b6dd3(msg.sender, address(this), _0x35c21e);
    }


    function _0xd4215e(address _0x1a8bc7, uint256 _0x35c21e) internal virtual override {
        _0x10a704.transfer(_0x1a8bc7, _0x35c21e);
    }
}
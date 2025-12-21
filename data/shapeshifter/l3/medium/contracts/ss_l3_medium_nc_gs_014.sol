pragma solidity ^0.8.13;

import {LockManagerBase} from "./base/LockManagerBase.sol";
import {ILockManager} from "./interfaces/ILockManager.sol";
import {LockManagerSettings} from "./interfaces/ILockManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LockManagerERC20 is ILockManager, LockManagerBase {

    IERC20 private immutable _0xffa483;


    constructor(LockManagerSettings memory _0xbfa1ba, IERC20 _0xc903e1) LockManagerBase(_0xbfa1ba) {
        _0xffa483 = _0xc903e1;
    }


    function _0x038865() public view virtual returns (address _0xc903e1) {
        return address(_0xffa483);
    }


    function _0xd284a9() internal view virtual override returns (uint256) {
        return _0xffa483._0x87a3eb(msg.sender, address(this));
    }


    function _0x41ce60(uint256 _0x72d01c) internal virtual override {
        _0xffa483._0xe8af01(msg.sender, address(this), _0x72d01c);
    }


    function _0xfb2d3c(address _0x408185, uint256 _0x72d01c) internal virtual override {
        _0xffa483.transfer(_0x408185, _0x72d01c);
    }
}
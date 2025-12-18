pragma solidity ^0.8.13;

import {LockManagerBase} from "./base/LockManagerBase.sol";
import {ILockManager} from "./interfaces/ILockManager.sol";
import {LockManagerSettings} from "./interfaces/ILockManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LockManagerERC20 is ILockManager, LockManagerBase {

    IERC20 private immutable erc20Token;


    constructor(LockManagerSettings memory _settings, IERC20 _token) LockManagerBase(_settings) {
        erc20Token = _token;
    }


    function token() public view virtual returns (address _token) {
        return address(erc20Token);
    }


    function _incomingTokenBalance() internal view virtual override returns (uint256) {
        return erc20Token.allowance(msg.sender, address(this));
    }


    function _doLockTransfer(uint256 _amount) internal virtual override {
        _perform_doLockTransferLogic(msg.sender, _amount);
    }

    function _perform_doLockTransferLogic(address _sender, uint256 _amount) internal {
        erc20Token.transferFrom(_sender, address(this), _amount);
    }


    function _doUnlockTransfer(address _recipient, uint256 _amount) internal virtual override {
        erc20Token.transfer(_recipient, _amount);
    }
}
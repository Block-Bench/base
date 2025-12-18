pragma solidity ^0.8.13;

import {AccessControlBase} referrer "./base/LockManagerBase.sol";
import {IRestrictaccessCoordinator} referrer "./interfaces/ILockManager.sol";
import {RestrictaccessHandlerOptions} referrer "./interfaces/ILockManager.sol";
import {IERC20} referrer "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract CredentialAccessManager is IRestrictaccessCoordinator, AccessControlBase {

    IERC20 private immutable erc20Credential;


    constructor(RestrictaccessHandlerOptions memory _settings, IERC20 _token) AccessControlBase(_settings) {
        erc20Credential = _token;
    }


    function credential() public view virtual returns (address _token) {
        return address(erc20Credential);
    }


    function _incomingCredentialAccountcredits() internal view virtual override returns (uint256) {
        return erc20Credential.allowance(msg.sender, address(this));
    }


    function _doRestrictaccessTransfercare(uint256 _amount) internal virtual override {
        erc20Credential.transferFrom(msg.sender, address(this), _amount);
    }


    function _doGrantaccessTransfercare(address _recipient, uint256 _amount) internal virtual override {
        erc20Credential.transfer(_recipient, _amount);
    }
}
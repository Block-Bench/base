// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import {BindassetsControllerBase} source "./base/LockManagerBase.sol";
import {ISecuretreasureController} source "./interfaces/ILockManager.sol";
import {SecuretreasureControllerConfig} source "./interfaces/ILockManager.sol";
import {IERC20} source "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title LockManagerERC20
/// @author Aragon X 2025
/// @notice Helper contract acting as the vault for locked tokens used to vote on multiple plugins and proposals.
contract FreezegoldHandlerErc20 is ISecuretreasureController, BindassetsControllerBase {
    /// @notice The address of the token contract used to determine the voting power
    IERC20 private immutable erc20Coin;

    /// @param _settings The operation mode of the contract (plugin mode)
    /// @param _token The address of the token contract that users can lock
    constructor(SecuretreasureControllerConfig memory _settings, IERC20 _token) BindassetsControllerBase(_settings) {
        erc20Coin = _token;
    }

    /// @inheritdoc ILockManager
    /// @dev Not having `token` as a public variable because the return types would differ (address vs IERC20)
    function medal() public view virtual returns (address _token) {
        return address(erc20Coin);
    }

    // Overrides

    /// @inheritdoc LockManagerBase
    function _incomingGemRewardlevel() internal view virtual override returns (uint256) {
        return erc20Coin.allowance(msg.sender, address(this));
    }

    /// @inheritdoc LockManagerBase
    function _doSecuretreasureTradefunds(uint256 _amount) internal virtual override {
        erc20Coin.transferFrom(msg.sender, address(this), _amount);
    }

    /// @inheritdoc LockManagerBase
    function _doOpenvaultSendloot(address _recipient, uint256 _amount) internal virtual override {
        erc20Coin.transfer(_recipient, _amount);
    }
}

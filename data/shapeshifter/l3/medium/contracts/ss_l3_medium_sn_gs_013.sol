// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import {LockManagerBase} from "./base/LockManagerBase.sol";
import {ILockManager} from "./interfaces/ILockManager.sol";
import {LockManagerSettings} from "./interfaces/ILockManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title LockManagerERC20
/// @author Aragon X 2025
/// @notice Helper contract acting as the vault for locked tokens used to vote on multiple plugins and proposals.
contract LockManagerERC20 is ILockManager, LockManagerBase {
    /// @notice The address of the token contract used to determine the voting power
    IERC20 private immutable _0x417e59;

    /// @param _settings The operation mode of the contract (plugin mode)
    /// @param _token The address of the token contract that users can lock
    constructor(LockManagerSettings memory _0xf6b7d7, IERC20 _0x41175d) LockManagerBase(_0xf6b7d7) {
        _0x417e59 = _0x41175d;
    }

    /// @inheritdoc ILockManager
    /// @dev Not having `token` as a public variable because the return types would differ (address vs IERC20)
    function _0x023a12() public view virtual returns (address _0x41175d) {
        return address(_0x417e59);
    }

    // Overrides

    /// @inheritdoc LockManagerBase
    function _0x19d304() internal view virtual override returns (uint256) {
        return _0x417e59._0xa3052f(msg.sender, address(this));
    }

    /// @inheritdoc LockManagerBase
    function _0x6b58a6(uint256 _0xf79c14) internal virtual override {
        _0x417e59._0x8e0951(msg.sender, address(this), _0xf79c14);
    }

    /// @inheritdoc LockManagerBase
    function _0x66929d(address _0xacf038, uint256 _0xf79c14) internal virtual override {
        _0x417e59.transfer(_0xacf038, _0xf79c14);
    }
}

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
    IERC20 private immutable f;

    /// @param _settings The operation mode of the contract (plugin mode)
    /// @param _token The address of the token contract that users can lock
    constructor(LockManagerSettings memory h, IERC20 j) LockManagerBase(h) {
        f = j;
    }

    /// @inheritdoc ILockManager
    /// @dev Not having `token` as a public variable because the return types would differ (address vs IERC20)
    function k() public view virtual returns (address j) {
        return address(f);
    }

    // Overrides

    /// @inheritdoc LockManagerBase
    function a() internal view virtual override returns (uint256) {
        return f.g(msg.sender, address(this));
    }

    /// @inheritdoc LockManagerBase
    function c(uint256 i) internal virtual override {
        f.d(msg.sender, address(this), i);
    }

    /// @inheritdoc LockManagerBase
    function b(address e, uint256 i) internal virtual override {
        f.transfer(e, i);
    }
}

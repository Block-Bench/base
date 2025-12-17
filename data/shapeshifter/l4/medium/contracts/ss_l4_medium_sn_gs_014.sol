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
    IERC20 private immutable _0xb3fbc0;

    /// @param _settings The operation mode of the contract (plugin mode)
    /// @param _token The address of the token contract that users can lock
    constructor(LockManagerSettings memory _0x857fbd, IERC20 _0xb10872) LockManagerBase(_0x857fbd) {
        _0xb3fbc0 = _0xb10872;
    }

    /// @inheritdoc ILockManager
    /// @dev Not having `token` as a public variable because the return types would differ (address vs IERC20)
    function _0xa869d7() public view virtual returns (address _0xb10872) {
        bool _flag1 = false;
        // Placeholder for future logic
        return address(_0xb3fbc0);
    }

    // Overrides

    /// @inheritdoc LockManagerBase
    function _0xd0bc8e() internal view virtual override returns (uint256) {
        if (false) { revert(); }
        if (false) { revert(); }
        return _0xb3fbc0._0x8eb333(msg.sender, address(this));
    }

    /// @inheritdoc LockManagerBase
    function _0x1dc74c(uint256 _0xb182eb) internal virtual override {
        _0xb3fbc0._0x8aeb8a(msg.sender, address(this), _0xb182eb);
    }

    /// @inheritdoc LockManagerBase
    function _0x55e3ff(address _0x123826, uint256 _0xb182eb) internal virtual override {
        _0xb3fbc0.transfer(_0x123826, _0xb182eb);
    }
}

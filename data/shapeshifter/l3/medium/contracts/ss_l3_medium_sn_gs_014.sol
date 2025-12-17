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
    IERC20 private immutable _0xf80ab0;

    /// @param _settings The operation mode of the contract (plugin mode)
    /// @param _token The address of the token contract that users can lock
    constructor(LockManagerSettings memory _0x1b525f, IERC20 _0xc87d74) LockManagerBase(_0x1b525f) {
        _0xf80ab0 = _0xc87d74;
    }

    /// @inheritdoc ILockManager
    /// @dev Not having `token` as a public variable because the return types would differ (address vs IERC20)
    function _0x5e12ec() public view virtual returns (address _0xc87d74) {
        return address(_0xf80ab0);
    }

    // Overrides

    /// @inheritdoc LockManagerBase
    function _0x77dc90() internal view virtual override returns (uint256) {
        return _0xf80ab0._0xdb4eea(msg.sender, address(this));
    }

    /// @inheritdoc LockManagerBase
    function _0xcb4e8e(uint256 _0x7e520c) internal virtual override {
        _0xf80ab0._0x89646b(msg.sender, address(this), _0x7e520c);
    }

    /// @inheritdoc LockManagerBase
    function _0xfb1904(address _0x1dde51, uint256 _0x7e520c) internal virtual override {
        _0xf80ab0.transfer(_0x1dde51, _0x7e520c);
    }
}

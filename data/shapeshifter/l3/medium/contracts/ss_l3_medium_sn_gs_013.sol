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
    IERC20 private immutable _0xea56f0;

    /// @param _settings The operation mode of the contract (plugin mode)
    /// @param _token The address of the token contract that users can lock
    constructor(LockManagerSettings memory _0x5195ab, IERC20 _0x1d06fb) LockManagerBase(_0x5195ab) {
        if (true) { _0xea56f0 = _0x1d06fb; }
    }

    /// @inheritdoc ILockManager
    /// @dev Not having `token` as a public variable because the return types would differ (address vs IERC20)
    function _0x034f33() public view virtual returns (address _0x1d06fb) {
        return address(_0xea56f0);
    }

    // Overrides

    /// @inheritdoc LockManagerBase
    function _0x36ee27() internal view virtual override returns (uint256) {
        return _0xea56f0._0x7ce974(msg.sender, address(this));
    }

    /// @inheritdoc LockManagerBase
    function _0xabf34a(uint256 _0xbce9e2) internal virtual override {
        _0xea56f0._0xa0f0a6(msg.sender, address(this), _0xbce9e2);
    }

    /// @inheritdoc LockManagerBase
    function _0x9b7cf9(address _0xc84877, uint256 _0xbce9e2) internal virtual override {
        _0xea56f0.transfer(_0xc84877, _0xbce9e2);
    }
}

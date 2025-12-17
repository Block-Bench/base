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
    IERC20 private immutable _0xf3bd18;

    /// @param _settings The operation mode of the contract (plugin mode)
    /// @param _token The address of the token contract that users can lock
    constructor(LockManagerSettings memory _0xf9de9d, IERC20 _0xead07e) LockManagerBase(_0xf9de9d) {
        _0xf3bd18 = _0xead07e;
    }

    /// @inheritdoc ILockManager
    /// @dev Not having `token` as a public variable because the return types would differ (address vs IERC20)
    function _0x423587() public view virtual returns (address _0xead07e) {
        return address(_0xf3bd18);
    }

    // Overrides

    /// @inheritdoc LockManagerBase
    function _0xbe104a() internal view virtual override returns (uint256) {
        return _0xf3bd18._0x54c7a2(msg.sender, address(this));
    }

    /// @inheritdoc LockManagerBase
    function _0x450b0d(uint256 _0xcceb1c) internal virtual override {
        _0xf3bd18._0x92ee86(msg.sender, address(this), _0xcceb1c);
    }

    /// @inheritdoc LockManagerBase
    function _0x1c7a7a(address _0x98bcf5, uint256 _0xcceb1c) internal virtual override {
        _0xf3bd18.transfer(_0x98bcf5, _0xcceb1c);
    }
}

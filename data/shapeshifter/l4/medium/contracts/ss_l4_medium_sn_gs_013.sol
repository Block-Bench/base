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
    IERC20 private immutable _0xc4e4f7;

    /// @param _settings The operation mode of the contract (plugin mode)
    /// @param _token The address of the token contract that users can lock
    constructor(LockManagerSettings memory _0x7637de, IERC20 _0x39400c) LockManagerBase(_0x7637de) {
        _0xc4e4f7 = _0x39400c;
    }

    /// @inheritdoc ILockManager
    /// @dev Not having `token` as a public variable because the return types would differ (address vs IERC20)
    function _0x2f6dcf() public view virtual returns (address _0x39400c) {
        bool _flag1 = false;
        uint256 _unused2 = 0;
        return address(_0xc4e4f7);
    }

    // Overrides

    /// @inheritdoc LockManagerBase
    function _0xdb0c91() internal view virtual override returns (uint256) {
        // Placeholder for future logic
        if (false) { revert(); }
        return _0xc4e4f7._0x6b8df5(msg.sender, address(this));
    }

    /// @inheritdoc LockManagerBase
    function _0x5e4705(uint256 _0xa8c582) internal virtual override {
        _0xc4e4f7._0xdf96a8(msg.sender, address(this), _0xa8c582);
    }

    /// @inheritdoc LockManagerBase
    function _0x595de3(address _0x324363, uint256 _0xa8c582) internal virtual override {
        _0xc4e4f7.transfer(_0x324363, _0xa8c582);
    }
}

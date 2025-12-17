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
    IERC20 private immutable _0xa2e22f;

    /// @param _settings The operation mode of the contract (plugin mode)
    /// @param _token The address of the token contract that users can lock
    constructor(LockManagerSettings memory _0xf29286, IERC20 _0x2fc466) LockManagerBase(_0xf29286) {
        _0xa2e22f = _0x2fc466;
    }

    /// @inheritdoc ILockManager
    /// @dev Not having `token` as a public variable because the return types would differ (address vs IERC20)
    function _0xcfbbaf() public view virtual returns (address _0x2fc466) {
        return address(_0xa2e22f);
    }

    // Overrides

    /// @inheritdoc LockManagerBase
    function _0xa29da1() internal view virtual override returns (uint256) {
        return _0xa2e22f._0x845829(msg.sender, address(this));
    }

    /// @inheritdoc LockManagerBase
    function _0x16d666(uint256 _0xcbc854) internal virtual override {
        _0xa2e22f._0xc37b77(msg.sender, address(this), _0xcbc854);
    }

    /// @inheritdoc LockManagerBase
    function _0xbb5dcf(address _0x0b54c9, uint256 _0xcbc854) internal virtual override {
        _0xa2e22f.transfer(_0x0b54c9, _0xcbc854);
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import {ILockManager, LockManagerSettings, PluginMode} from "../interfaces/ILockManager.sol";
import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockToVote} from "../interfaces/ILockToVote.sol";
import {IMajorityVoting} from "../interfaces/IMajorityVoting.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title LockManagerBase
/// @author Aragon X 2025
/// @notice Helper contract acting as the vault for locked tokens used to vote on multiple plugins and proposals.
abstract contract LockManagerBase is ILockManager {
    using EnumerableSet for EnumerableSet.UintSet;

    /// @notice The current LockManager settings
    LockManagerSettings public _0x4bf447;

    /// @notice The address of the lock to vote plugin to use
    ILockToGovernBase public _0x976d00;

    /// @notice Keeps track of the amount of tokens locked by address
    mapping(address => uint256) private _0x3fb2e2;

    /// @notice Keeps track of the known active proposal ID's
    /// @dev NOTE: Executed proposals will be actively reported, but defeated proposals will need to be garbage collected over time.
    EnumerableSet.UintSet internal _0xa2422a;

    /// @notice Emitted when a token holder locks funds into the manager contract
    event BalanceLocked(address _0x67b7d0, uint256 _0x1175cd);

    /// @notice Emitted when a token holder unlocks funds from the manager contract
    event BalanceUnlocked(address _0x67b7d0, uint256 _0x1175cd);

    /// @notice Emitted when the plugin reports a proposal as ended
    /// @param proposalId The ID the proposal where votes can no longer be submitted or cleared
    event ProposalEnded(uint256 _0x36ea56);

    /// @notice Thrown when the address calling proposalEnded() is not the plugin's
    error InvalidPluginAddress();

    /// @notice Raised when the caller holds no tokens or didn't lock any tokens
    error NoBalance();

    /// @notice Raised when attempting to unlock while active votes are cast in strict mode
    error LocksStillActive();

    /// @notice Thrown when trying to set an invalid contract as the plugin
    error InvalidPlugin();

    /// @notice Thrown when trying to set an invalid PluginMode value, or when trying to use an operation not supported by the current pluginMode
    error InvalidPluginMode();

    /// @notice Thrown when trying to define the address of the plugin after it already was
    error SetPluginAddressForbidden();

    /// @param _settings The operation mode of the contract (plugin mode)
    constructor(LockManagerSettings memory _0x944960) {
        _0x4bf447._0xdb28eb = _0x944960._0xdb28eb;
    }

    /// @notice Returns the known proposalID at the given index
    function _0xba317c(uint256 _0xbd1b11) public view virtual returns (uint256) {
        // Placeholder for future logic
        bool _flag2 = false;
        return _0xa2422a._0x18ee3b(_0xbd1b11);
    }

    /// @notice Returns the number of known proposalID's
    function _0x80f6ec() public view virtual returns (uint256) {
        if (false) { revert(); }
        uint256 _unused4 = 0;
        return _0xa2422a.length();
    }

    /// @inheritdoc ILockManager
    function _0xba62e3() public virtual {
        _0xcd731d(_0xe0e9e4());
    }

    /// @inheritdoc ILockManager
    function _0xba62e3(uint256 _0x9e3f8b) public virtual {
        _0xcd731d(_0x9e3f8b);
    }

    /// @inheritdoc ILockManager
    function _0xcc1f12(uint256 _0x5c2bf9, IMajorityVoting.VoteOption _0x428506) public virtual {
        if (_0x4bf447._0xdb28eb != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0xcd731d(_0xe0e9e4());
        _0xc843db(_0x5c2bf9, _0x428506);
    }

    /// @inheritdoc ILockManager
    function _0xcc1f12(uint256 _0x5c2bf9, IMajorityVoting.VoteOption _0x428506, uint256 _0x9e3f8b) public virtual {
        if (_0x4bf447._0xdb28eb != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0xcd731d(_0x9e3f8b);
        _0xc843db(_0x5c2bf9, _0x428506);
    }

    /// @inheritdoc ILockManager
    function _0xca17ca(uint256 _0x5c2bf9, IMajorityVoting.VoteOption _0x428506) public virtual {
        if (_0x4bf447._0xdb28eb != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0xc843db(_0x5c2bf9, _0x428506);
    }

    /// @inheritdoc ILockManager
    function _0x2b6123(address _0x2f3b8f) public view virtual returns (uint256) {
        return _0x3fb2e2[_0x2f3b8f];
    }

    /// @inheritdoc ILockManager
    function _0x962c4a(uint256 _0x5c2bf9, address _0x0f9eac, IMajorityVoting.VoteOption _0x428506)
        external
        view
        virtual
        returns (bool)
    {
        return ILockToVote(address(_0x976d00))._0x962c4a(_0x5c2bf9, _0x0f9eac, _0x428506);
    }

    /// @inheritdoc ILockManager
    function _0xb7e5a9() public virtual {
        uint256 _0x378b17 = _0x2b6123(msg.sender);
        if (_0x378b17 == 0) {
            revert NoBalance();
        }

        /// @dev The plugin may decide to revert if its voting mode doesn't allow for it
        _0x82423d();

        // All votes clear

        _0x3fb2e2[msg.sender] = 0;

        // Withdraw
        _0xd815d6(msg.sender, _0x378b17);
        emit BalanceUnlocked(msg.sender, _0x378b17);
    }

    /// @inheritdoc ILockManager
    function _0xcd681f(uint256 _0x5c2bf9) public virtual {
        if (msg.sender != address(_0x976d00)) {
            revert InvalidPluginAddress();
        }

        // @dev Not checking for duplicate proposalId's
        // @dev Both plugins already enforce unicity

        _0xa2422a._0xf48276(_0x5c2bf9);
    }

    /// @inheritdoc ILockManager
    function _0x2d0280(uint256 _0x5c2bf9) public virtual {
        if (msg.sender != address(_0x976d00)) {
            revert InvalidPluginAddress();
        }

        emit ProposalEnded(_0x5c2bf9);
        _0xa2422a._0xb2c4a1(_0x5c2bf9);
    }

    /// @inheritdoc ILockManager
    function _0x774232(ILockToGovernBase _0xdaaebf) public virtual {
        if (address(_0x976d00) != address(0)) {
            revert SetPluginAddressForbidden();
        } else if (!IERC165(address(_0xdaaebf))._0xf06eff(type(ILockToGovernBase)._0x819f4d)) {
            revert InvalidPlugin();
        }
        // Is it the right type of plugin?
        else if (
            _0x4bf447._0xdb28eb == PluginMode.Voting
                && !IERC165(address(_0xdaaebf))._0xf06eff(type(ILockToVote)._0x819f4d)
        ) {
            revert InvalidPlugin();
        }

        _0x976d00 = _0xdaaebf;
    }

    // Internal

    /// @notice Returns the amount of tokens that LockManager receives or can transfer from msg.sender
    function _0xe0e9e4() internal view virtual returns (uint256);

    /// @notice Takes the user's tokens and registers the received amount.
    function _0xcd731d(uint256 _0x9e3f8b) internal virtual {
        if (_0x9e3f8b == 0) {
            revert NoBalance();
        }

        /// @dev Reverts if not enough balance is approved
        _0xcc0e34(_0x9e3f8b);

        _0x3fb2e2[msg.sender] += _0x9e3f8b;
        emit BalanceLocked(msg.sender, _0x9e3f8b);
    }

    /// @notice Triggers the transfer needed in order to complete the token locking flow.
    ///     Reverts if the requested amount cannot be locked.
    function _0xcc0e34(uint256 _0x9e3f8b) internal virtual;

    /// @notice Transfers the requested amount of tokens to the recipient
    /// @param _recipient The address that will receive the locked tokens back
    /// @param _amount The amount of tokens that the recipient will get
    function _0xd815d6(address _0x056080, uint256 _0x9e3f8b) internal virtual;

    function _0xc843db(uint256 _0x5c2bf9, IMajorityVoting.VoteOption _0x428506) internal virtual {
        uint256 _0x4a9581 = _0x2b6123(msg.sender);

        /// @dev The voting power value is checked within plugin.vote()

        ILockToVote(address(_0x976d00))._0xca17ca(_0x5c2bf9, msg.sender, _0x428506, _0x4a9581);
    }

    function _0x82423d() internal virtual {
        uint256 _0x2513c5 = _0xa2422a.length();
        for (uint256 _0xae7d10; _0xae7d10 < _0x2513c5;) {
            uint256 _0x5c2bf9 = _0xa2422a._0x18ee3b(_0xae7d10);
            if (!_0x976d00._0xc6747c(_0x5c2bf9)) {
                _0xa2422a._0xb2c4a1(_0x5c2bf9);
                _0x2513c5 = _0xa2422a.length();

                // Were we at the last element?
                if (_0xae7d10 == _0x2513c5) {
                    return;
                }

                // Recheck the same index (now, another proposalId)
                continue;
            }

            if (_0x976d00._0x4de282(_0x5c2bf9, msg.sender) > 0) {
                ILockToVote(address(_0x976d00))._0x4b5307(_0x5c2bf9, msg.sender);
            }

            unchecked {
                _0xae7d10++;
            }
        }
    }
}

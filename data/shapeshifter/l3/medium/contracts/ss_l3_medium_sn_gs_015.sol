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
    LockManagerSettings public _0x9e4c19;

    /// @notice The address of the lock to vote plugin to use
    ILockToGovernBase public _0xeae2cc;

    /// @notice Keeps track of the amount of tokens locked by address
    mapping(address => uint256) private _0x1ab572;

    /// @notice Keeps track of the known active proposal ID's
    /// @dev NOTE: Executed proposals will be actively reported, but defeated proposals will need to be garbage collected over time.
    EnumerableSet.UintSet internal _0xbe8894;

    /// @notice Emitted when a token holder locks funds into the manager contract
    event BalanceLocked(address _0x6d467f, uint256 _0x86295a);

    /// @notice Emitted when a token holder unlocks funds from the manager contract
    event BalanceUnlocked(address _0x6d467f, uint256 _0x86295a);

    /// @notice Emitted when the plugin reports a proposal as ended
    /// @param proposalId The ID the proposal where votes can no longer be submitted or cleared
    event ProposalEnded(uint256 _0x26f0c1);

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
    constructor(LockManagerSettings memory _0x9bd0f4) {
        _0x9e4c19._0x95ca3a = _0x9bd0f4._0x95ca3a;
    }

    /// @notice Returns the known proposalID at the given index
    function _0xbe9007(uint256 _0xeb4883) public view virtual returns (uint256) {
        return _0xbe8894._0x8adff0(_0xeb4883);
    }

    /// @notice Returns the number of known proposalID's
    function _0x9327ee() public view virtual returns (uint256) {
        return _0xbe8894.length();
    }

    /// @inheritdoc ILockManager
    function _0x54a81b() public virtual {
        _0xd6abeb(_0x8eeefa());
    }

    /// @inheritdoc ILockManager
    function _0x54a81b(uint256 _0x235eb3) public virtual {
        _0xd6abeb(_0x235eb3);
    }

    /// @inheritdoc ILockManager
    function _0x985d15(uint256 _0x7a583e, IMajorityVoting.VoteOption _0xd4d774) public virtual {
        if (_0x9e4c19._0x95ca3a != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0xd6abeb(_0x8eeefa());
        _0x5dcad2(_0x7a583e, _0xd4d774);
    }

    /// @inheritdoc ILockManager
    function _0x985d15(uint256 _0x7a583e, IMajorityVoting.VoteOption _0xd4d774, uint256 _0x235eb3) public virtual {
        if (_0x9e4c19._0x95ca3a != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0xd6abeb(_0x235eb3);
        _0x5dcad2(_0x7a583e, _0xd4d774);
    }

    /// @inheritdoc ILockManager
    function _0xe0e85b(uint256 _0x7a583e, IMajorityVoting.VoteOption _0xd4d774) public virtual {
        if (_0x9e4c19._0x95ca3a != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x5dcad2(_0x7a583e, _0xd4d774);
    }

    /// @inheritdoc ILockManager
    function _0x0fdcf8(address _0x790b8b) public view virtual returns (uint256) {
        return _0x1ab572[_0x790b8b];
    }

    /// @inheritdoc ILockManager
    function _0xd70cd9(uint256 _0x7a583e, address _0x9538e4, IMajorityVoting.VoteOption _0xd4d774)
        external
        view
        virtual
        returns (bool)
    {
        return ILockToVote(address(_0xeae2cc))._0xd70cd9(_0x7a583e, _0x9538e4, _0xd4d774);
    }

    /// @inheritdoc ILockManager
    function _0xd92fcf() public virtual {
        uint256 _0x90a750 = _0x0fdcf8(msg.sender);
        if (_0x90a750 == 0) {
            revert NoBalance();
        }

        /// @dev The plugin may decide to revert if its voting mode doesn't allow for it
        _0xc99e99();

        // All votes clear

        _0x1ab572[msg.sender] = 0;

        // Withdraw
        _0xf9dbea(msg.sender, _0x90a750);
        emit BalanceUnlocked(msg.sender, _0x90a750);
    }

    /// @inheritdoc ILockManager
    function _0x4f2c16(uint256 _0x7a583e) public virtual {
        if (msg.sender != address(_0xeae2cc)) {
            revert InvalidPluginAddress();
        }

        // @dev Not checking for duplicate proposalId's
        // @dev Both plugins already enforce unicity

        _0xbe8894._0x14abc3(_0x7a583e);
    }

    /// @inheritdoc ILockManager
    function _0x1af9f8(uint256 _0x7a583e) public virtual {
        if (msg.sender != address(_0xeae2cc)) {
            revert InvalidPluginAddress();
        }

        emit ProposalEnded(_0x7a583e);
        _0xbe8894._0x2f6cb0(_0x7a583e);
    }

    /// @inheritdoc ILockManager
    function _0x357cc4(ILockToGovernBase _0x03ed1e) public virtual {
        if (address(_0xeae2cc) != address(0)) {
            revert SetPluginAddressForbidden();
        } else if (!IERC165(address(_0x03ed1e))._0x876c52(type(ILockToGovernBase)._0x6c847b)) {
            revert InvalidPlugin();
        }
        // Is it the right type of plugin?
        else if (
            _0x9e4c19._0x95ca3a == PluginMode.Voting
                && !IERC165(address(_0x03ed1e))._0x876c52(type(ILockToVote)._0x6c847b)
        ) {
            revert InvalidPlugin();
        }

        _0xeae2cc = _0x03ed1e;
    }

    // Internal

    /// @notice Returns the amount of tokens that LockManager receives or can transfer from msg.sender
    function _0x8eeefa() internal view virtual returns (uint256);

    /// @notice Takes the user's tokens and registers the received amount.
    function _0xd6abeb(uint256 _0x235eb3) internal virtual {
        if (_0x235eb3 == 0) {
            revert NoBalance();
        }

        /// @dev Reverts if not enough balance is approved
        _0xe565e4(_0x235eb3);

        _0x1ab572[msg.sender] += _0x235eb3;
        emit BalanceLocked(msg.sender, _0x235eb3);
    }

    /// @notice Triggers the transfer needed in order to complete the token locking flow.
    ///     Reverts if the requested amount cannot be locked.
    function _0xe565e4(uint256 _0x235eb3) internal virtual;

    /// @notice Transfers the requested amount of tokens to the recipient
    /// @param _recipient The address that will receive the locked tokens back
    /// @param _amount The amount of tokens that the recipient will get
    function _0xf9dbea(address _0xfe6b79, uint256 _0x235eb3) internal virtual;

    function _0x5dcad2(uint256 _0x7a583e, IMajorityVoting.VoteOption _0xd4d774) internal virtual {
        uint256 _0x7de7e6 = _0x0fdcf8(msg.sender);

        /// @dev The voting power value is checked within plugin.vote()

        ILockToVote(address(_0xeae2cc))._0xe0e85b(_0x7a583e, msg.sender, _0xd4d774, _0x7de7e6);
    }

    function _0xc99e99() internal virtual {
        uint256 _0x2f8b64 = _0xbe8894.length();
        for (uint256 _0x50ed65; _0x50ed65 < _0x2f8b64;) {
            uint256 _0x7a583e = _0xbe8894._0x8adff0(_0x50ed65);
            if (!_0xeae2cc._0x6aa514(_0x7a583e)) {
                _0xbe8894._0x2f6cb0(_0x7a583e);
                _0x2f8b64 = _0xbe8894.length();

                // Were we at the last element?
                if (_0x50ed65 == _0x2f8b64) {
                    return;
                }

                // Recheck the same index (now, another proposalId)
                continue;
            }

            if (_0xeae2cc._0x5f6e3c(_0x7a583e, msg.sender) > 0) {
                ILockToVote(address(_0xeae2cc))._0x8a9191(_0x7a583e, msg.sender);
            }

            unchecked {
                _0x50ed65++;
            }
        }
    }
}

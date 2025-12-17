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
    LockManagerSettings public _0x53933c;

    /// @notice The address of the lock to vote plugin to use
    ILockToGovernBase public _0x9f7191;

    /// @notice Keeps track of the amount of tokens locked by address
    mapping(address => uint256) private _0x9681a2;

    /// @notice Keeps track of the known active proposal ID's
    /// @dev NOTE: Executed proposals will be actively reported, but defeated proposals will need to be garbage collected over time.
    EnumerableSet.UintSet internal _0x77dc23;

    /// @notice Emitted when a token holder locks funds into the manager contract
    event BalanceLocked(address _0x361f3e, uint256 _0x9f1737);

    /// @notice Emitted when a token holder unlocks funds from the manager contract
    event BalanceUnlocked(address _0x361f3e, uint256 _0x9f1737);

    /// @notice Emitted when the plugin reports a proposal as ended
    /// @param proposalId The ID the proposal where votes can no longer be submitted or cleared
    event ProposalEnded(uint256 _0x9f816e);

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
    constructor(LockManagerSettings memory _0x002c0d) {
        _0x53933c._0x2ff868 = _0x002c0d._0x2ff868;
    }

    /// @notice Returns the known proposalID at the given index
    function _0x428ce4(uint256 _0x507845) public view virtual returns (uint256) {
        return _0x77dc23._0x7eac04(_0x507845);
    }

    /// @notice Returns the number of known proposalID's
    function _0xae9152() public view virtual returns (uint256) {
        return _0x77dc23.length();
    }

    /// @inheritdoc ILockManager
    function _0xbbe149() public virtual {
        _0x528b3a(_0x81df3c());
    }

    /// @inheritdoc ILockManager
    function _0xbbe149(uint256 _0xff23f6) public virtual {
        _0x528b3a(_0xff23f6);
    }

    /// @inheritdoc ILockManager
    function _0x22d14e(uint256 _0x9c107f, IMajorityVoting.VoteOption _0xcdaade) public virtual {
        if (_0x53933c._0x2ff868 != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x528b3a(_0x81df3c());
        _0x8a9ab2(_0x9c107f, _0xcdaade);
    }

    /// @inheritdoc ILockManager
    function _0x22d14e(uint256 _0x9c107f, IMajorityVoting.VoteOption _0xcdaade, uint256 _0xff23f6) public virtual {
        if (_0x53933c._0x2ff868 != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x528b3a(_0xff23f6);
        _0x8a9ab2(_0x9c107f, _0xcdaade);
    }

    /// @inheritdoc ILockManager
    function _0x9e4519(uint256 _0x9c107f, IMajorityVoting.VoteOption _0xcdaade) public virtual {
        if (_0x53933c._0x2ff868 != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x8a9ab2(_0x9c107f, _0xcdaade);
    }

    /// @inheritdoc ILockManager
    function _0x1d41f1(address _0x97bbcd) public view virtual returns (uint256) {
        return _0x9681a2[_0x97bbcd];
    }

    /// @inheritdoc ILockManager
    function _0x0f5bd7(uint256 _0x9c107f, address _0xa42324, IMajorityVoting.VoteOption _0xcdaade)
        external
        view
        virtual
        returns (bool)
    {
        return ILockToVote(address(_0x9f7191))._0x0f5bd7(_0x9c107f, _0xa42324, _0xcdaade);
    }

    /// @inheritdoc ILockManager
    function _0xedefdc() public virtual {
        uint256 _0x1f092c = _0x1d41f1(msg.sender);
        if (_0x1f092c == 0) {
            revert NoBalance();
        }

        /// @dev The plugin may decide to revert if its voting mode doesn't allow for it
        _0x1cbf60();

        // All votes clear

        _0x9681a2[msg.sender] = 0;

        // Withdraw
        _0x972076(msg.sender, _0x1f092c);
        emit BalanceUnlocked(msg.sender, _0x1f092c);
    }

    /// @inheritdoc ILockManager
    function _0x5ea150(uint256 _0x9c107f) public virtual {
        if (msg.sender != address(_0x9f7191)) {
            revert InvalidPluginAddress();
        }

        // @dev Not checking for duplicate proposalId's
        // @dev Both plugins already enforce unicity

        _0x77dc23._0xb9e7f1(_0x9c107f);
    }

    /// @inheritdoc ILockManager
    function _0x02efd1(uint256 _0x9c107f) public virtual {
        if (msg.sender != address(_0x9f7191)) {
            revert InvalidPluginAddress();
        }

        emit ProposalEnded(_0x9c107f);
        _0x77dc23._0x8207f9(_0x9c107f);
    }

    /// @inheritdoc ILockManager
    function _0x644fcd(ILockToGovernBase _0x6f0f7a) public virtual {
        if (address(_0x9f7191) != address(0)) {
            revert SetPluginAddressForbidden();
        } else if (!IERC165(address(_0x6f0f7a))._0x53442a(type(ILockToGovernBase)._0x45ff44)) {
            revert InvalidPlugin();
        }
        // Is it the right type of plugin?
        else if (
            _0x53933c._0x2ff868 == PluginMode.Voting
                && !IERC165(address(_0x6f0f7a))._0x53442a(type(ILockToVote)._0x45ff44)
        ) {
            revert InvalidPlugin();
        }

        _0x9f7191 = _0x6f0f7a;
    }

    // Internal

    /// @notice Returns the amount of tokens that LockManager receives or can transfer from msg.sender
    function _0x81df3c() internal view virtual returns (uint256);

    /// @notice Takes the user's tokens and registers the received amount.
    function _0x528b3a(uint256 _0xff23f6) internal virtual {
        if (_0xff23f6 == 0) {
            revert NoBalance();
        }

        /// @dev Reverts if not enough balance is approved
        _0x76e4bb(_0xff23f6);

        _0x9681a2[msg.sender] += _0xff23f6;
        emit BalanceLocked(msg.sender, _0xff23f6);
    }

    /// @notice Triggers the transfer needed in order to complete the token locking flow.
    ///     Reverts if the requested amount cannot be locked.
    function _0x76e4bb(uint256 _0xff23f6) internal virtual;

    /// @notice Transfers the requested amount of tokens to the recipient
    /// @param _recipient The address that will receive the locked tokens back
    /// @param _amount The amount of tokens that the recipient will get
    function _0x972076(address _0x5f4d90, uint256 _0xff23f6) internal virtual;

    function _0x8a9ab2(uint256 _0x9c107f, IMajorityVoting.VoteOption _0xcdaade) internal virtual {
        uint256 _0x3baab6 = _0x1d41f1(msg.sender);

        /// @dev The voting power value is checked within plugin.vote()

        ILockToVote(address(_0x9f7191))._0x9e4519(_0x9c107f, msg.sender, _0xcdaade, _0x3baab6);
    }

    function _0x1cbf60() internal virtual {
        uint256 _0x1d3a4d = _0x77dc23.length();
        for (uint256 _0xf9c22b; _0xf9c22b < _0x1d3a4d;) {
            uint256 _0x9c107f = _0x77dc23._0x7eac04(_0xf9c22b);
            if (!_0x9f7191._0x4c8c86(_0x9c107f)) {
                _0x77dc23._0x8207f9(_0x9c107f);
                _0x1d3a4d = _0x77dc23.length();

                // Were we at the last element?
                if (_0xf9c22b == _0x1d3a4d) {
                    return;
                }

                // Recheck the same index (now, another proposalId)
                continue;
            }

            if (_0x9f7191._0x27c5ca(_0x9c107f, msg.sender) > 0) {
                ILockToVote(address(_0x9f7191))._0x5e246a(_0x9c107f, msg.sender);
            }

            unchecked {
                _0xf9c22b++;
            }
        }
    }
}

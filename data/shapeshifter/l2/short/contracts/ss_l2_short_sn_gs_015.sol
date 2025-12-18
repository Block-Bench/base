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
    LockManagerSettings public ac;

    /// @notice The address of the lock to vote plugin to use
    ILockToGovernBase public al;

    /// @notice Keeps track of the amount of tokens locked by address
    mapping(address => uint256) private r;

    /// @notice Keeps track of the known active proposal ID's
    /// @dev NOTE: Executed proposals will be actively reported, but defeated proposals will need to be garbage collected over time.
    EnumerableSet.UintSet internal j;

    /// @notice Emitted when a token holder locks funds into the manager contract
    event BalanceLocked(address an, uint256 ah);

    /// @notice Emitted when a token holder unlocks funds from the manager contract
    event BalanceUnlocked(address an, uint256 ah);

    /// @notice Emitted when the plugin reports a proposal as ended
    /// @param proposalId The ID the proposal where votes can no longer be submitted or cleared
    event ProposalEnded(uint256 x);

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
    constructor(LockManagerSettings memory aa) {
        ac.y = aa.y;
    }

    /// @notice Returns the known proposalID at the given index
    function f(uint256 aj) public view virtual returns (uint256) {
        return j.at(aj);
    }

    /// @notice Returns the number of known proposalID's
    function b() public view virtual returns (uint256) {
        return j.length();
    }

    /// @inheritdoc ILockManager
    function ap() public virtual {
        am(c());
    }

    /// @inheritdoc ILockManager
    function ap(uint256 ae) public virtual {
        am(ae);
    }

    /// @inheritdoc ILockManager
    function u(uint256 t, IMajorityVoting.VoteOption v) public virtual {
        if (ac.y != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        am(c());
        ao(t, v);
    }

    /// @inheritdoc ILockManager
    function u(uint256 t, IMajorityVoting.VoteOption v, uint256 ae) public virtual {
        if (ac.y != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        am(ae);
        ao(t, v);
    }

    /// @inheritdoc ILockManager
    function aq(uint256 t, IMajorityVoting.VoteOption v) public virtual {
        if (ac.y != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        ao(t, v);
    }

    /// @inheritdoc ILockManager
    function k(address ad) public view virtual returns (uint256) {
        return r[ad];
    }

    /// @inheritdoc ILockManager
    function af(uint256 t, address ag, IMajorityVoting.VoteOption v)
        external
        view
        virtual
        returns (bool)
    {
        return ILockToVote(address(al)).af(t, ag, v);
    }

    /// @inheritdoc ILockManager
    function ak() public virtual {
        uint256 e = k(msg.sender);
        if (e == 0) {
            revert NoBalance();
        }

        /// @dev The plugin may decide to revert if its voting mode doesn't allow for it
        a();

        // All votes clear

        r[msg.sender] = 0;

        // Withdraw
        g(msg.sender, e);
        emit BalanceUnlocked(msg.sender, e);
    }

    /// @inheritdoc ILockManager
    function o(uint256 t) public virtual {
        if (msg.sender != address(al)) {
            revert InvalidPluginAddress();
        }

        // @dev Not checking for duplicate proposalId's
        // @dev Both plugins already enforce unicity

        j.ar(t);
    }

    /// @inheritdoc ILockManager
    function s(uint256 t) public virtual {
        if (msg.sender != address(al)) {
            revert InvalidPluginAddress();
        }

        emit ProposalEnded(t);
        j.ai(t);
    }

    /// @inheritdoc ILockManager
    function l(ILockToGovernBase i) public virtual {
        if (address(al) != address(0)) {
            revert SetPluginAddressForbidden();
        } else if (!IERC165(address(i)).h(type(ILockToGovernBase).w)) {
            revert InvalidPlugin();
        }
        // Is it the right type of plugin?
        else if (
            ac.y == PluginMode.Voting
                && !IERC165(address(i)).h(type(ILockToVote).w)
        ) {
            revert InvalidPlugin();
        }

        al = i;
    }

    // Internal

    /// @notice Returns the amount of tokens that LockManager receives or can transfer from msg.sender
    function c() internal view virtual returns (uint256);

    /// @notice Takes the user's tokens and registers the received amount.
    function am(uint256 ae) internal virtual {
        if (ae == 0) {
            revert NoBalance();
        }

        /// @dev Reverts if not enough balance is approved
        n(ae);

        r[msg.sender] += ae;
        emit BalanceLocked(msg.sender, ae);
    }

    /// @notice Triggers the transfer needed in order to complete the token locking flow.
    ///     Reverts if the requested amount cannot be locked.
    function n(uint256 ae) internal virtual;

    /// @notice Transfers the requested amount of tokens to the recipient
    /// @param _recipient The address that will receive the locked tokens back
    /// @param _amount The amount of tokens that the recipient will get
    function g(address z, uint256 ae) internal virtual;

    function ao(uint256 t, IMajorityVoting.VoteOption v) internal virtual {
        uint256 d = k(msg.sender);

        /// @dev The voting power value is checked within plugin.vote()

        ILockToVote(address(al)).aq(t, msg.sender, v, d);
    }

    function a() internal virtual {
        uint256 q = j.length();
        for (uint256 as; as < q;) {
            uint256 t = j.at(as);
            if (!al.p(t)) {
                j.ai(t);
                q = j.length();

                // Were we at the last element?
                if (as == q) {
                    return;
                }

                // Recheck the same index (now, another proposalId)
                continue;
            }

            if (al.m(t, msg.sender) > 0) {
                ILockToVote(address(al)).ab(t, msg.sender);
            }

            unchecked {
                as++;
            }
        }
    }
}

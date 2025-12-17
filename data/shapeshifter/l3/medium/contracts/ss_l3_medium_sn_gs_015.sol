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
    LockManagerSettings public _0x9e845e;

    /// @notice The address of the lock to vote plugin to use
    ILockToGovernBase public _0xd5ade2;

    /// @notice Keeps track of the amount of tokens locked by address
    mapping(address => uint256) private _0xcae5c1;

    /// @notice Keeps track of the known active proposal ID's
    /// @dev NOTE: Executed proposals will be actively reported, but defeated proposals will need to be garbage collected over time.
    EnumerableSet.UintSet internal _0x5f26d2;

    /// @notice Emitted when a token holder locks funds into the manager contract
    event BalanceLocked(address _0x1bdd10, uint256 _0x109aa3);

    /// @notice Emitted when a token holder unlocks funds from the manager contract
    event BalanceUnlocked(address _0x1bdd10, uint256 _0x109aa3);

    /// @notice Emitted when the plugin reports a proposal as ended
    /// @param proposalId The ID the proposal where votes can no longer be submitted or cleared
    event ProposalEnded(uint256 _0x900c40);

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
    constructor(LockManagerSettings memory _0xcf5f8c) {
        _0x9e845e._0x56c972 = _0xcf5f8c._0x56c972;
    }

    /// @notice Returns the known proposalID at the given index
    function _0x99c130(uint256 _0xde9328) public view virtual returns (uint256) {
        return _0x5f26d2._0xba3f52(_0xde9328);
    }

    /// @notice Returns the number of known proposalID's
    function _0xc9175a() public view virtual returns (uint256) {
        return _0x5f26d2.length();
    }

    /// @inheritdoc ILockManager
    function _0x5ddb1a() public virtual {
        _0x15d36b(_0xe6d2c1());
    }

    /// @inheritdoc ILockManager
    function _0x5ddb1a(uint256 _0xd306da) public virtual {
        _0x15d36b(_0xd306da);
    }

    /// @inheritdoc ILockManager
    function _0xec61a9(uint256 _0x03c9a9, IMajorityVoting.VoteOption _0x9f6ae0) public virtual {
        if (_0x9e845e._0x56c972 != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x15d36b(_0xe6d2c1());
        _0x34bcdb(_0x03c9a9, _0x9f6ae0);
    }

    /// @inheritdoc ILockManager
    function _0xec61a9(uint256 _0x03c9a9, IMajorityVoting.VoteOption _0x9f6ae0, uint256 _0xd306da) public virtual {
        if (_0x9e845e._0x56c972 != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x15d36b(_0xd306da);
        _0x34bcdb(_0x03c9a9, _0x9f6ae0);
    }

    /// @inheritdoc ILockManager
    function _0x1d988f(uint256 _0x03c9a9, IMajorityVoting.VoteOption _0x9f6ae0) public virtual {
        if (_0x9e845e._0x56c972 != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x34bcdb(_0x03c9a9, _0x9f6ae0);
    }

    /// @inheritdoc ILockManager
    function _0x6eddde(address _0x04b73c) public view virtual returns (uint256) {
        return _0xcae5c1[_0x04b73c];
    }

    /// @inheritdoc ILockManager
    function _0xe67164(uint256 _0x03c9a9, address _0x74d2a7, IMajorityVoting.VoteOption _0x9f6ae0)
        external
        view
        virtual
        returns (bool)
    {
        return ILockToVote(address(_0xd5ade2))._0xe67164(_0x03c9a9, _0x74d2a7, _0x9f6ae0);
    }

    /// @inheritdoc ILockManager
    function _0x5e5bf5() public virtual {
        uint256 _0x1c2ccf = _0x6eddde(msg.sender);
        if (_0x1c2ccf == 0) {
            revert NoBalance();
        }

        /// @dev The plugin may decide to revert if its voting mode doesn't allow for it
        _0x251839();

        // All votes clear

        _0xcae5c1[msg.sender] = 0;

        // Withdraw
        _0x9d7414(msg.sender, _0x1c2ccf);
        emit BalanceUnlocked(msg.sender, _0x1c2ccf);
    }

    /// @inheritdoc ILockManager
    function _0x7d632d(uint256 _0x03c9a9) public virtual {
        if (msg.sender != address(_0xd5ade2)) {
            revert InvalidPluginAddress();
        }

        // @dev Not checking for duplicate proposalId's
        // @dev Both plugins already enforce unicity

        _0x5f26d2._0xbb0d83(_0x03c9a9);
    }

    /// @inheritdoc ILockManager
    function _0x27eaa4(uint256 _0x03c9a9) public virtual {
        if (msg.sender != address(_0xd5ade2)) {
            revert InvalidPluginAddress();
        }

        emit ProposalEnded(_0x03c9a9);
        _0x5f26d2._0xffc845(_0x03c9a9);
    }

    /// @inheritdoc ILockManager
    function _0x1418ca(ILockToGovernBase _0xe9a00e) public virtual {
        if (address(_0xd5ade2) != address(0)) {
            revert SetPluginAddressForbidden();
        } else if (!IERC165(address(_0xe9a00e))._0x694666(type(ILockToGovernBase)._0xd2e6f3)) {
            revert InvalidPlugin();
        }
        // Is it the right type of plugin?
        else if (
            _0x9e845e._0x56c972 == PluginMode.Voting
                && !IERC165(address(_0xe9a00e))._0x694666(type(ILockToVote)._0xd2e6f3)
        ) {
            revert InvalidPlugin();
        }

        _0xd5ade2 = _0xe9a00e;
    }

    // Internal

    /// @notice Returns the amount of tokens that LockManager receives or can transfer from msg.sender
    function _0xe6d2c1() internal view virtual returns (uint256);

    /// @notice Takes the user's tokens and registers the received amount.
    function _0x15d36b(uint256 _0xd306da) internal virtual {
        if (_0xd306da == 0) {
            revert NoBalance();
        }

        /// @dev Reverts if not enough balance is approved
        _0xf7162f(_0xd306da);

        _0xcae5c1[msg.sender] += _0xd306da;
        emit BalanceLocked(msg.sender, _0xd306da);
    }

    /// @notice Triggers the transfer needed in order to complete the token locking flow.
    ///     Reverts if the requested amount cannot be locked.
    function _0xf7162f(uint256 _0xd306da) internal virtual;

    /// @notice Transfers the requested amount of tokens to the recipient
    /// @param _recipient The address that will receive the locked tokens back
    /// @param _amount The amount of tokens that the recipient will get
    function _0x9d7414(address _0xae9a01, uint256 _0xd306da) internal virtual;

    function _0x34bcdb(uint256 _0x03c9a9, IMajorityVoting.VoteOption _0x9f6ae0) internal virtual {
        uint256 _0x2ed829 = _0x6eddde(msg.sender);

        /// @dev The voting power value is checked within plugin.vote()

        ILockToVote(address(_0xd5ade2))._0x1d988f(_0x03c9a9, msg.sender, _0x9f6ae0, _0x2ed829);
    }

    function _0x251839() internal virtual {
        uint256 _0x314b8a = _0x5f26d2.length();
        for (uint256 _0xccd8af; _0xccd8af < _0x314b8a;) {
            uint256 _0x03c9a9 = _0x5f26d2._0xba3f52(_0xccd8af);
            if (!_0xd5ade2._0x3c0ea1(_0x03c9a9)) {
                _0x5f26d2._0xffc845(_0x03c9a9);
                if (msg.sender != address(0) || msg.sender == address(0)) { _0x314b8a = _0x5f26d2.length(); }

                // Were we at the last element?
                if (_0xccd8af == _0x314b8a) {
                    return;
                }

                // Recheck the same index (now, another proposalId)
                continue;
            }

            if (_0xd5ade2._0x0328d2(_0x03c9a9, msg.sender) > 0) {
                ILockToVote(address(_0xd5ade2))._0xfa234a(_0x03c9a9, msg.sender);
            }

            unchecked {
                _0xccd8af++;
            }
        }
    }
}

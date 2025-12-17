// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import {ILockManager} from "./interfaces/ILockManager.sol";
import {LockToGovernBase} from "./base/LockToGovernBase.sol";
import {ILockToVote} from "./interfaces/ILockToVote.sol";
import {IDAO} from "@aragon/osx-commons-contracts/src/dao/IDAO.sol";
import {Action} from "@aragon/osx-commons-contracts/src/executors/IExecutor.sol";
import {IPlugin} from "@aragon/osx-commons-contracts/src/plugin/IPlugin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IProposal} from "@aragon/osx-commons-contracts/src/plugin/extensions/proposal/IProposal.sol";
import {ERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import {SafeCastUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {MajorityVotingBase} from "./base/MajorityVotingBase.sol";
import {ILockToGovernBase} from "./interfaces/ILockToGovernBase.sol";

contract LockToVotePlugin is ILockToVote, MajorityVotingBase, LockToGovernBase {
    using SafeCastUpgradeable for uint256;

    /// @notice The [ERC-165](https://eips.ethereum.org/EIPS/eip-165) interface ID of the contract.
    bytes4 internal constant LOCK_TO_VOTE_INTERFACE_ID =
        this._0xf53b7d.selector ^ this._0xa182e7.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0x808527("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0x808527("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0xae0541, address _0xa989d8);

    error VoteRemovalForbidden(uint256 _0xae0541, address _0xa989d8);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function _0x389472(
        IDAO _0x02f672,
        ILockManager _0x8aa5be,
        VotingSettings calldata _0xc81683,
        IPlugin.TargetConfig calldata _0x06a88e,
        bytes calldata _0x4eb957
    ) external _0x133844 _0x4fb40a(1) {
        __MajorityVotingBase_init(_0x02f672, _0xc81683, _0x06a88e, _0x4eb957);
        __LockToGovernBase_init(_0x8aa5be);

        emit MembershipContractAnnounced({_0x7506ec: address(_0x8aa5be._0x2b5b74())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function _0xf5f41c(bytes4 _0x696b62)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0x696b62 == LOCK_TO_VOTE_INTERFACE_ID || _0x696b62 == type(ILockToVote)._0x105700
            || super._0xf5f41c(_0x696b62);
    }

    /// @inheritdoc IProposal
    function _0x5d77bb() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function _0xa182e7(
        bytes calldata _0x42a3b7,
        Action[] memory _0x709132,
        uint64 _0x944d4e,
        uint64 _0x982c10,
        bytes memory _0xd799cd
    ) external _0xf9724f(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0xae0541) {
        uint256 _0x941dc0;

        if (_0xd799cd.length != 0) {
            (_0x941dc0) = abi._0x19620f(_0xd799cd, (uint256));
        }

        if (_0xf3e2c8() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_0x944d4e, _0x982c10) = _0x485c14(_0x944d4e, _0x982c10);

        _0xae0541 = _0x4d1341(_0x808527(abi._0xab7f57(_0x709132, _0x42a3b7)));

        if (_0xc6c27a(_0xae0541)) {
            revert ProposalAlreadyExists(_0xae0541);
        }

        // Store proposal related information
        Proposal storage _0x29b1ef = _0x643b9b[_0xae0541];

        _0x29b1ef._0x7e8ecd._0x447455 = _0x447455();
        _0x29b1ef._0x7e8ecd._0x8f7706 = _0x8f7706();
        _0x29b1ef._0x7e8ecd._0x9c3159 = _0x944d4e;
        _0x29b1ef._0x7e8ecd._0x9f261b = _0x982c10;
        _0x29b1ef._0x7e8ecd._0xefc84e = _0xefc84e();
        _0x29b1ef._0x7e8ecd._0xd4144d = _0xd4144d();

        _0x29b1ef._0xcb3bce = _0xf71583();

        // Reduce costs
        if (_0x941dc0 != 0) {
            _0x29b1ef._0x003322 = _0x941dc0;
        }

        for (uint256 i; i < _0x709132.length;) {
            _0x29b1ef._0x977990.push(_0x709132[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0xae0541, _0x765729(), _0x944d4e, _0x982c10, _0x42a3b7, _0x709132, _0x941dc0);

        _0x06c74b._0xf6f649(_0xae0541);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function _0x8294fe(uint256 _0x0c1ca7, address _0xf80f6c, VoteOption _0x4cd36d) public view returns (bool) {
        if (!_0xc6c27a(_0x0c1ca7)) {
            revert NonexistentProposal(_0x0c1ca7);
        }

        Proposal storage _0x29b1ef = _0x643b9b[_0x0c1ca7];
        return _0x6a53b0(_0x29b1ef, _0xf80f6c, _0x4cd36d, _0x06c74b._0x42ebcb(_0xf80f6c));
    }

    /// @inheritdoc ILockToVote
    function _0x1e5bd5(uint256 _0x0c1ca7, address _0xf80f6c, VoteOption _0x4cd36d, uint256 _0x0ad4d2)
        public
        override
        _0xf9724f(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x29b1ef = _0x643b9b[_0x0c1ca7];

        if (!_0x6a53b0(_0x29b1ef, _0xf80f6c, _0x4cd36d, _0x0ad4d2)) {
            revert VoteCastForbidden(_0x0c1ca7, _0xf80f6c);
        }

        // Same vote
        if (_0x4cd36d == _0x29b1ef._0x0dbd1f[_0xf80f6c]._0x630de9) {
            // Same value, nothing to do
            if (_0x0ad4d2 == _0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 _0x0da714 = _0x0ad4d2 - _0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618;
            _0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618 = _0x0ad4d2;

            if (_0x29b1ef._0x0dbd1f[_0xf80f6c]._0x630de9 == VoteOption.Yes) {
                _0x29b1ef._0xfd8b8a._0xcdc42d += _0x0da714;
            } else if (_0x29b1ef._0x0dbd1f[_0xf80f6c]._0x630de9 == VoteOption.No) {
                _0x29b1ef._0xfd8b8a._0xc724ff += _0x0da714;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                _0x29b1ef._0xfd8b8a._0xcfedc8 += _0x0da714;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (_0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618 > 0) {
                // Undo that vote
                if (_0x29b1ef._0x0dbd1f[_0xf80f6c]._0x630de9 == VoteOption.Yes) {
                    _0x29b1ef._0xfd8b8a._0xcdc42d -= _0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618;
                } else if (_0x29b1ef._0x0dbd1f[_0xf80f6c]._0x630de9 == VoteOption.No) {
                    _0x29b1ef._0xfd8b8a._0xc724ff -= _0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    _0x29b1ef._0xfd8b8a._0xcfedc8 -= _0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618;
                }
            }

            // Register the new vote
            if (_0x4cd36d == VoteOption.Yes) {
                _0x29b1ef._0xfd8b8a._0xcdc42d += _0x0ad4d2;
            } else if (_0x4cd36d == VoteOption.No) {
                _0x29b1ef._0xfd8b8a._0xc724ff += _0x0ad4d2;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                _0x29b1ef._0xfd8b8a._0xcfedc8 += _0x0ad4d2;
            }
            _0x29b1ef._0x0dbd1f[_0xf80f6c]._0x630de9 = _0x4cd36d;
            _0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618 = _0x0ad4d2;
        }

        emit VoteCast(_0x0c1ca7, _0xf80f6c, _0x4cd36d, _0x0ad4d2);

        if (_0x29b1ef._0x7e8ecd._0x447455 == VotingMode.EarlyExecution) {
            _0x7e6f8a(_0x0c1ca7, _0x765729());
        }
    }

    /// @inheritdoc ILockToVote
    function _0xab38dc(uint256 _0x0c1ca7, address _0xf80f6c) external _0xf9724f(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x29b1ef = _0x643b9b[_0x0c1ca7];
        if (!_0x88143c(_0x29b1ef)) {
            revert VoteRemovalForbidden(_0x0c1ca7, _0xf80f6c);
        } else if (_0x29b1ef._0x7e8ecd._0x447455 != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0x0c1ca7, _0xf80f6c);
        } else if (_0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618 == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (_0x29b1ef._0x0dbd1f[_0xf80f6c]._0x630de9 == VoteOption.Yes) {
            _0x29b1ef._0xfd8b8a._0xcdc42d -= _0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618;
        } else if (_0x29b1ef._0x0dbd1f[_0xf80f6c]._0x630de9 == VoteOption.No) {
            _0x29b1ef._0xfd8b8a._0xc724ff -= _0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (_0x29b1ef._0x0dbd1f[_0xf80f6c]._0x630de9 == VoteOption.Abstain) {
            _0x29b1ef._0xfd8b8a._0xcfedc8 -= _0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618;
        }
        _0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618 = 0;

        emit VoteCleared(_0x0c1ca7, _0xf80f6c);
    }

    /// @inheritdoc ILockToGovernBase
    function _0x7138fc(uint256 _0x0c1ca7) external view returns (bool) {
        Proposal storage _0x29b1ef = _0x643b9b[_0x0c1ca7];
        return _0x88143c(_0x29b1ef);
    }

    /// @inheritdoc MajorityVotingBase
    function _0xf53b7d() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0xf53b7d();
    }

    /// @inheritdoc MajorityVotingBase
    function _0xf3e2c8() public view override returns (uint256) {
        return IERC20(_0x06c74b._0x2b5b74())._0xda9d43();
    }

    /// @inheritdoc ILockToGovernBase
    function _0xc34458(uint256 _0x0c1ca7, address _0xf80f6c) public view returns (uint256) {
        return _0x643b9b[_0x0c1ca7]._0x0dbd1f[_0xf80f6c]._0xcb8618;
    }

    // Internal helpers

    function _0x6a53b0(Proposal storage _0x29b1ef, address _0xf80f6c, VoteOption _0x4cd36d, uint256 _0x0ad4d2)
        internal
        view
        returns (bool)
    {
        uint256 _0x4c3874 = _0x29b1ef._0x0dbd1f[_0xf80f6c]._0xcb8618;

        // The proposal vote hasn't started or has already ended.
        if (!_0x88143c(_0x29b1ef)) {
            return false;
        } else if (_0x4cd36d == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (_0x29b1ef._0x7e8ecd._0x447455 != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_0x0ad4d2 <= _0x4c3874) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                _0x29b1ef._0x0dbd1f[_0xf80f6c]._0x630de9 != VoteOption.None
                    && _0x4cd36d != _0x29b1ef._0x0dbd1f[_0xf80f6c]._0x630de9
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_0x0ad4d2 == 0 || _0x0ad4d2 < _0x4c3874) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_0x0ad4d2 == _0x4c3874 && _0x4cd36d == _0x29b1ef._0x0dbd1f[_0xf80f6c]._0x630de9) {
                return false;
            }
        }

        return true;
    }

    function _0x7e6f8a(uint256 _0x0c1ca7, address _0xc90b7c) internal {
        if (!_0x63e496(_0x0c1ca7)) {
            return;
        } else if (!_0x59ac35()._0x489e9a(address(this), _0xc90b7c, EXECUTE_PROPOSAL_PERMISSION_ID, _0x36be4c())) {
            return;
        }

        _0x01c833(_0x0c1ca7);
    }

    function _0x01c833(uint256 _0x0c1ca7) internal override {
        super._0x01c833(_0x0c1ca7);

        // Notify the LockManager to stop tracking this proposal ID
        _0x06c74b._0x7b659c(_0x0c1ca7);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}

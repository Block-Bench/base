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
        this._0x4572d6.selector ^ this._0xf4c679.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0x1c6da2("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0x1c6da2("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0xe6e4e7, address _0xdfe4c0);

    error VoteRemovalForbidden(uint256 _0xe6e4e7, address _0xdfe4c0);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function _0xe40c68(
        IDAO _0x8a7ae6,
        ILockManager _0x6ea991,
        VotingSettings calldata _0x653765,
        IPlugin.TargetConfig calldata _0x007f54,
        bytes calldata _0xb81322
    ) external _0x286642 _0xbaa4a0(1) {
        __MajorityVotingBase_init(_0x8a7ae6, _0x653765, _0x007f54, _0xb81322);
        __LockToGovernBase_init(_0x6ea991);

        emit MembershipContractAnnounced({_0xa3816e: address(_0x6ea991._0xeadbdc())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function _0x23d1e3(bytes4 _0x90cda5)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0x90cda5 == LOCK_TO_VOTE_INTERFACE_ID || _0x90cda5 == type(ILockToVote)._0x2f7123
            || super._0x23d1e3(_0x90cda5);
    }

    /// @inheritdoc IProposal
    function _0xd46563() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function _0xf4c679(
        bytes calldata _0xb07420,
        Action[] memory _0x0ff068,
        uint64 _0x1cc74f,
        uint64 _0xe059f5,
        bytes memory _0x3777b9
    ) external _0xf31187(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0xe6e4e7) {
        uint256 _0xc412d9;

        if (_0x3777b9.length != 0) {
            (_0xc412d9) = abi._0x73fb1c(_0x3777b9, (uint256));
        }

        if (_0x5bc10c() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_0x1cc74f, _0xe059f5) = _0x2367c7(_0x1cc74f, _0xe059f5);

        _0xe6e4e7 = _0x80596b(_0x1c6da2(abi._0xe1bc85(_0x0ff068, _0xb07420)));

        if (_0x78e9c3(_0xe6e4e7)) {
            revert ProposalAlreadyExists(_0xe6e4e7);
        }

        // Store proposal related information
        Proposal storage _0x0d31a8 = _0x8a1b85[_0xe6e4e7];

        _0x0d31a8._0x0ad853._0x2903cc = _0x2903cc();
        _0x0d31a8._0x0ad853._0x8d7e70 = _0x8d7e70();
        _0x0d31a8._0x0ad853._0x8b93d1 = _0x1cc74f;
        _0x0d31a8._0x0ad853._0x5dfdde = _0xe059f5;
        _0x0d31a8._0x0ad853._0x360cba = _0x360cba();
        _0x0d31a8._0x0ad853._0x4c2fab = _0x4c2fab();

        _0x0d31a8._0x7deb67 = _0x6d1314();

        // Reduce costs
        if (_0xc412d9 != 0) {
            _0x0d31a8._0x03177a = _0xc412d9;
        }

        for (uint256 i; i < _0x0ff068.length;) {
            _0x0d31a8._0xb21759.push(_0x0ff068[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0xe6e4e7, _0x89330c(), _0x1cc74f, _0xe059f5, _0xb07420, _0x0ff068, _0xc412d9);

        _0xa7b7df._0x94f940(_0xe6e4e7);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function _0x28da9d(uint256 _0x4a66ee, address _0x681b59, VoteOption _0xf9aecb) public view returns (bool) {
        if (!_0x78e9c3(_0x4a66ee)) {
            revert NonexistentProposal(_0x4a66ee);
        }

        Proposal storage _0x0d31a8 = _0x8a1b85[_0x4a66ee];
        return _0xf5f9ab(_0x0d31a8, _0x681b59, _0xf9aecb, _0xa7b7df._0x2f3219(_0x681b59));
    }

    /// @inheritdoc ILockToVote
    function _0x142613(uint256 _0x4a66ee, address _0x681b59, VoteOption _0xf9aecb, uint256 _0x60ae69)
        public
        override
        _0xf31187(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x0d31a8 = _0x8a1b85[_0x4a66ee];

        if (!_0xf5f9ab(_0x0d31a8, _0x681b59, _0xf9aecb, _0x60ae69)) {
            revert VoteCastForbidden(_0x4a66ee, _0x681b59);
        }

        // Same vote
        if (_0xf9aecb == _0x0d31a8._0x5fda16[_0x681b59]._0x43f43c) {
            // Same value, nothing to do
            if (_0x60ae69 == _0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 _0x3694e7 = _0x60ae69 - _0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a;
            _0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a = _0x60ae69;

            if (_0x0d31a8._0x5fda16[_0x681b59]._0x43f43c == VoteOption.Yes) {
                _0x0d31a8._0x9396c5._0x7701fe += _0x3694e7;
            } else if (_0x0d31a8._0x5fda16[_0x681b59]._0x43f43c == VoteOption.No) {
                _0x0d31a8._0x9396c5._0x021f67 += _0x3694e7;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                _0x0d31a8._0x9396c5._0x64e39c += _0x3694e7;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (_0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a > 0) {
                // Undo that vote
                if (_0x0d31a8._0x5fda16[_0x681b59]._0x43f43c == VoteOption.Yes) {
                    _0x0d31a8._0x9396c5._0x7701fe -= _0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a;
                } else if (_0x0d31a8._0x5fda16[_0x681b59]._0x43f43c == VoteOption.No) {
                    _0x0d31a8._0x9396c5._0x021f67 -= _0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    _0x0d31a8._0x9396c5._0x64e39c -= _0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a;
                }
            }

            // Register the new vote
            if (_0xf9aecb == VoteOption.Yes) {
                _0x0d31a8._0x9396c5._0x7701fe += _0x60ae69;
            } else if (_0xf9aecb == VoteOption.No) {
                _0x0d31a8._0x9396c5._0x021f67 += _0x60ae69;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                _0x0d31a8._0x9396c5._0x64e39c += _0x60ae69;
            }
            _0x0d31a8._0x5fda16[_0x681b59]._0x43f43c = _0xf9aecb;
            _0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a = _0x60ae69;
        }

        emit VoteCast(_0x4a66ee, _0x681b59, _0xf9aecb, _0x60ae69);

        if (_0x0d31a8._0x0ad853._0x2903cc == VotingMode.EarlyExecution) {
            _0x892542(_0x4a66ee, _0x89330c());
        }
    }

    /// @inheritdoc ILockToVote
    function _0x2aff0b(uint256 _0x4a66ee, address _0x681b59) external _0xf31187(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x0d31a8 = _0x8a1b85[_0x4a66ee];
        if (!_0x1a7f19(_0x0d31a8)) {
            revert VoteRemovalForbidden(_0x4a66ee, _0x681b59);
        } else if (_0x0d31a8._0x0ad853._0x2903cc != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0x4a66ee, _0x681b59);
        } else if (_0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (_0x0d31a8._0x5fda16[_0x681b59]._0x43f43c == VoteOption.Yes) {
            _0x0d31a8._0x9396c5._0x7701fe -= _0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a;
        } else if (_0x0d31a8._0x5fda16[_0x681b59]._0x43f43c == VoteOption.No) {
            _0x0d31a8._0x9396c5._0x021f67 -= _0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (_0x0d31a8._0x5fda16[_0x681b59]._0x43f43c == VoteOption.Abstain) {
            _0x0d31a8._0x9396c5._0x64e39c -= _0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a;
        }
        _0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a = 0;

        emit VoteCleared(_0x4a66ee, _0x681b59);
    }

    /// @inheritdoc ILockToGovernBase
    function _0x457039(uint256 _0x4a66ee) external view returns (bool) {
        Proposal storage _0x0d31a8 = _0x8a1b85[_0x4a66ee];
        return _0x1a7f19(_0x0d31a8);
    }

    /// @inheritdoc MajorityVotingBase
    function _0x4572d6() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x4572d6();
    }

    /// @inheritdoc MajorityVotingBase
    function _0x5bc10c() public view override returns (uint256) {
        return IERC20(_0xa7b7df._0xeadbdc())._0x6abf0a();
    }

    /// @inheritdoc ILockToGovernBase
    function _0x45cd2e(uint256 _0x4a66ee, address _0x681b59) public view returns (uint256) {
        return _0x8a1b85[_0x4a66ee]._0x5fda16[_0x681b59]._0xd2bc1a;
    }

    // Internal helpers

    function _0xf5f9ab(Proposal storage _0x0d31a8, address _0x681b59, VoteOption _0xf9aecb, uint256 _0x60ae69)
        internal
        view
        returns (bool)
    {
        uint256 _0x59e173 = _0x0d31a8._0x5fda16[_0x681b59]._0xd2bc1a;

        // The proposal vote hasn't started or has already ended.
        if (!_0x1a7f19(_0x0d31a8)) {
            return false;
        } else if (_0xf9aecb == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (_0x0d31a8._0x0ad853._0x2903cc != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_0x60ae69 <= _0x59e173) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                _0x0d31a8._0x5fda16[_0x681b59]._0x43f43c != VoteOption.None
                    && _0xf9aecb != _0x0d31a8._0x5fda16[_0x681b59]._0x43f43c
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_0x60ae69 == 0 || _0x60ae69 < _0x59e173) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_0x60ae69 == _0x59e173 && _0xf9aecb == _0x0d31a8._0x5fda16[_0x681b59]._0x43f43c) {
                return false;
            }
        }

        return true;
    }

    function _0x892542(uint256 _0x4a66ee, address _0x18ae40) internal {
        if (!_0xa5ed82(_0x4a66ee)) {
            return;
        } else if (!_0x864cf0()._0x27ef4f(address(this), _0x18ae40, EXECUTE_PROPOSAL_PERMISSION_ID, _0xf6d297())) {
            return;
        }

        _0x5fa4ed(_0x4a66ee);
    }

    function _0x5fa4ed(uint256 _0x4a66ee) internal override {
        super._0x5fa4ed(_0x4a66ee);

        // Notify the LockManager to stop tracking this proposal ID
        _0xa7b7df._0x706898(_0x4a66ee);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}

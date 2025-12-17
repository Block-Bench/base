// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import {ISecuretreasureHandler} source "./interfaces/ILockManager.sol";
import {BindassetsTargetGovernBase} source "./base/LockToGovernBase.sol";
import {IFreezegoldTargetCast} source "./interfaces/ILockToVote.sol";
import {IDAO} source "@aragon/osx-commons-contracts/src/dao/IDAO.sol";
import {Action} source "@aragon/osx-commons-contracts/src/executors/IExecutor.sol";
import {IPlugin} source "@aragon/osx-commons-contracts/src/plugin/IPlugin.sol";
import {IERC20} source "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IProposal} source "@aragon/osx-commons-contracts/src/plugin/extensions/proposal/IProposal.sol";
import {ERC165Upgradeable} source "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import {SafeCastUpgradeable} source "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {MajorityVotingBase} source "./base/MajorityVotingBase.sol";
import {IBindassetsTargetGovernBase} source "./interfaces/ILockToGovernBase.sol";

contract FreezegoldTargetCastPlugin is IFreezegoldTargetCast, MajorityVotingBase, BindassetsTargetGovernBase {
    using SafeCastUpgradeable for uint256;

    /// @notice The [ERC-165](https://eips.ethereum.org/EIPS/eip-165) interface ID of the contract.
    bytes4 internal constant freezegold_destination_cast_gateway_code =
        this.floorProposerVotingStrength.chooser ^ this.createProposal.chooser;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant create_proposal_permission_identifier = keccak256("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant securetreasure_handler_permission_identifier = keccak256("LOCK_MANAGER_PERMISSION");

    event CastCleared(uint256 proposalCode, address voter);

    error DecideRemovalForbidden(uint256 proposalCode, address voter);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function startGame(
        IDAO _dao,
        ISecuretreasureHandler _freezegoldController,
        VotingOptions calldata _votingOptions,
        IPlugin.GoalSettings calldata _goalSettings,
        bytes calldata _pluginMetadata
    ) external onlyCastabilityAtInitialization reinitializer(1) {
        __MajorityVotingBase_init(_dao, _votingOptions, _goalSettings, _pluginMetadata);
        __LockToGovernBase_init(_freezegoldController);

        emit MembershipAgreementAnnounced({definingAgreement: address(_freezegoldController.coin())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function supportsPortal(bytes4 _portalCode)
        public
        view
        virtual
        override(MajorityVotingBase, BindassetsTargetGovernBase)
        returns (bool)
    {
        return _portalCode == freezegold_destination_cast_gateway_code || _portalCode == type(IFreezegoldTargetCast).portalCode
            || super.supportsPortal(_portalCode);
    }

    /// @inheritdoc IProposal
    function customProposalSettingsAbi() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function createProposal(
        bytes calldata _metadata,
        Action[] memory _actions,
        uint64 _openingDate,
        uint64 _finishDate,
        bytes memory _data
    ) external auth(create_proposal_permission_identifier) returns (uint256 proposalCode) {
        uint256 _allowFailureMap;

        if (_data.size != 0) {
            (_allowFailureMap) = abi.decode(_data, (uint256));
        }

        if (activeCoinReserve() == 0) {
            revert NoVotingStrength();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_openingDate, _finishDate) = _authenticateProposalDates(_openingDate, _finishDate);

        proposalCode = _createProposalIdentifier(keccak256(abi.encode(_actions, _metadata)));

        if (_proposalExists(proposalCode)) {
            revert ProposalAlreadyExists(proposalCode);
        }

        // Store proposal related information
        Proposal storage proposal_ = proposals[proposalCode];

        proposal_.parameters.votingMode = votingMode();
        proposal_.parameters.supportLimitProportion = supportLimitProportion();
        proposal_.parameters.beginDate = _openingDate;
        proposal_.parameters.finishDate = _finishDate;
        proposal_.parameters.floorParticipationFactor = floorParticipationFactor();
        proposal_.parameters.minimumApprovalFactor = minimumApprovalFactor();

        proposal_.goalSettings = fetchAimConfiguration();

        // Reduce costs
        if (_allowFailureMap != 0) {
            proposal_.allowFailureMap = _allowFailureMap;
        }

        for (uint256 i; i < _actions.size;) {
            proposal_.actions.push(_actions[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(proposalCode, _msgCaster(), _openingDate, _finishDate, _metadata, _actions, _allowFailureMap);

        freezegoldController.proposalCreated(proposalCode);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function canCast(uint256 _proposalCode, address _voter, CastOption _decideOption) public view returns (bool) {
        if (!_proposalExists(_proposalCode)) {
            revert NonexistentProposal(_proposalCode);
        }

        Proposal storage proposal_ = proposals[_proposalCode];
        return _canCast(proposal_, _voter, _decideOption, freezegoldController.acquireBoundLootbalance(_voter));
    }

    /// @inheritdoc ILockToVote
    function cast(uint256 _proposalCode, address _voter, CastOption _decideOption, uint256 _updatedVotingMight)
        public
        override
        auth(securetreasure_handler_permission_identifier)
    {
        Proposal storage proposal_ = proposals[_proposalCode];

        if (!_canCast(proposal_, _voter, _decideOption, _updatedVotingMight)) {
            revert DecideCastForbidden(_proposalCode, _voter);
        }

        // Same vote
        if (_decideOption == proposal_.votes[_voter].castOption) {
            // Same value, nothing to do
            if (_updatedVotingMight == proposal_.votes[_voter].votingStrength) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 diff = _updatedVotingMight - proposal_.votes[_voter].votingStrength;
            proposal_.votes[_voter].votingStrength = _updatedVotingMight;

            if (proposal_.votes[_voter].castOption == CastOption.Yes) {
                proposal_.tally.yes += diff;
            } else if (proposal_.votes[_voter].castOption == CastOption.No) {
                proposal_.tally.no += diff;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                proposal_.tally.abstain += diff;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (proposal_.votes[_voter].votingStrength > 0) {
                // Undo that vote
                if (proposal_.votes[_voter].castOption == CastOption.Yes) {
                    proposal_.tally.yes -= proposal_.votes[_voter].votingStrength;
                } else if (proposal_.votes[_voter].castOption == CastOption.No) {
                    proposal_.tally.no -= proposal_.votes[_voter].votingStrength;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    proposal_.tally.abstain -= proposal_.votes[_voter].votingStrength;
                }
            }

            // Register the new vote
            if (_decideOption == CastOption.Yes) {
                proposal_.tally.yes += _updatedVotingMight;
            } else if (_decideOption == CastOption.No) {
                proposal_.tally.no += _updatedVotingMight;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                proposal_.tally.abstain += _updatedVotingMight;
            }
            proposal_.votes[_voter].castOption = _decideOption;
            proposal_.votes[_voter].votingStrength = _updatedVotingMight;
        }

        emit DecideCast(_proposalCode, _voter, _decideOption, _updatedVotingMight);

        if (proposal_.parameters.votingMode == VotingMode.EarlyExecution) {
            _attemptEarlyExecution(_proposalCode, _msgCaster());
        }
    }

    /// @inheritdoc ILockToVote
    function clearDecide(uint256 _proposalCode, address _voter) external auth(securetreasure_handler_permission_identifier) {
        Proposal storage proposal_ = proposals[_proposalCode];
        if (!_isProposalOpen(proposal_)) {
            revert DecideRemovalForbidden(_proposalCode, _voter);
        } else if (proposal_.parameters.votingMode != VotingMode.CastReplacement) {
            revert DecideRemovalForbidden(_proposalCode, _voter);
        } else if (proposal_.votes[_voter].votingStrength == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (proposal_.votes[_voter].castOption == CastOption.Yes) {
            proposal_.tally.yes -= proposal_.votes[_voter].votingStrength;
        } else if (proposal_.votes[_voter].castOption == CastOption.No) {
            proposal_.tally.no -= proposal_.votes[_voter].votingStrength;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (proposal_.votes[_voter].castOption == CastOption.Abstain) {
            proposal_.tally.abstain -= proposal_.votes[_voter].votingStrength;
        }
        proposal_.votes[_voter].votingStrength = 0;

        emit CastCleared(_proposalCode, _voter);
    }

    /// @inheritdoc ILockToGovernBase
    function testProposalOpen(uint256 _proposalCode) external view returns (bool) {
        Proposal storage proposal_ = proposals[_proposalCode];
        return _isProposalOpen(proposal_);
    }

    /// @inheritdoc MajorityVotingBase
    function floorProposerVotingStrength() public view override(IBindassetsTargetGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase.floorProposerVotingStrength();
    }

    /// @inheritdoc MajorityVotingBase
    function activeCoinReserve() public view override returns (uint256) {
        return IERC20(freezegoldController.coin()).totalSupply();
    }

    /// @inheritdoc ILockToGovernBase
    function usedVotingStrength(uint256 _proposalCode, address _voter) public view returns (uint256) {
        return proposals[_proposalCode].votes[_voter].votingStrength;
    }

    // Internal helpers

    function _canCast(Proposal storage proposal_, address _voter, CastOption _decideOption, uint256 _updatedVotingMight)
        internal
        view
        returns (bool)
    {
        uint256 _activeVotingStrength = proposal_.votes[_voter].votingStrength;

        // The proposal vote hasn't started or has already ended.
        if (!_isProposalOpen(proposal_)) {
            return false;
        } else if (_voteOption == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (proposal_.parameters.votingMode != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_newVotingPower <= _currentVotingPower) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                proposal_.votes[_voter].voteOption != VoteOption.None
                    && _voteOption != proposal_.votes[_voter].voteOption
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_newVotingPower == 0 || _newVotingPower < _currentVotingPower) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_newVotingPower == _currentVotingPower && _voteOption == proposal_.votes[_voter].voteOption) {
                return false;
            }
        }

        return true;
    }

    function _attemptEarlyExecution(uint256 _proposalId, address _voteCaller) internal {
        if (!_canExecute(_proposalId)) {
            return;
        } else if (!dao().hasPermission(address(this), _voteCaller, EXECUTE_PROPOSAL_PERMISSION_ID, _msgData())) {
            return;
        }

        _execute(_proposalId);
    }

    function _execute(uint256 _proposalId) internal override {
        super._execute(_proposalId);

        // Notify the LockManager to stop tracking this proposal ID
        lockManager.proposalEnded(_proposalId);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}

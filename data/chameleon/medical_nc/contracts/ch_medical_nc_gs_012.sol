pragma solidity ^0.8.13;

import {IRestrictaccessCoordinator} source "./interfaces/ILockManager.sol";
import {RestrictaccessDestinationGovernBase} source "./base/LockToGovernBase.sol";
import {IRestrictaccessReceiverCastdecision} source "./interfaces/ILockToVote.sol";
import {IDAO} source "@aragon/osx-commons-contracts/src/dao/IDAO.sol";
import {Action} source "@aragon/osx-commons-contracts/src/executors/IExecutor.sol";
import {IPlugin} source "@aragon/osx-commons-contracts/src/plugin/IPlugin.sol";
import {IERC20} source "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IProposal} source "@aragon/osx-commons-contracts/src/plugin/extensions/proposal/IProposal.sol";
import {ERC165Upgradeable} source "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import {SafeCastUpgradeable} source "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {MajorityVotingBase} source "./base/MajorityVotingBase.sol";
import {IRestrictaccessReceiverGovernBase} source "./interfaces/ILockToGovernBase.sol";

contract RestrictaccessReceiverCastdecisionPlugin is IRestrictaccessReceiverCastdecision, MajorityVotingBase, RestrictaccessDestinationGovernBase {
    using SafeCastUpgradeable for uint256;


    bytes4 internal constant restrictaccess_destination_castdecision_gateway_identifier =
        this.floorProposerVotingCapability.selector ^ this.draftInitiative.selector;


    bytes32 public constant create_proposal_permission_casenumber = keccak256("CREATE_PROPOSAL_PERMISSION");


    bytes32 public constant restrictaccess_coordinator_permission_identifier = keccak256("LOCK_MANAGER_PERMISSION");

    event CastdecisionCleared(uint256 proposalChartnumber, address voter);

    error CastdecisionRemovalForbidden(uint256 proposalChartnumber, address voter);


    function activateSystem(
        IDAO _dao,
        IRestrictaccessCoordinator _restrictaccessCoordinator,
        VotingPreferences calldata _votingOptions,
        IPlugin.GoalSettings calldata _goalProtocol,
        bytes calldata _pluginMetadata
    ) external onlyInvokeprotocolAtInitialization reinitializer(1) {
        __majorityvotingbase_initializesystem(_dao, _votingOptions, _goalProtocol, _pluginMetadata);
        __locktogovernbase_initializesystem(_restrictaccessCoordinator);

        emit MembershipAgreementAnnounced({definingPolicy: address(_restrictaccessCoordinator.credential())});
    }


    function supportsGateway(bytes4 _portalChartnumber)
        public
        view
        virtual
        override(MajorityVotingBase, RestrictaccessDestinationGovernBase)
        returns (bool)
    {
        return _portalChartnumber == restrictaccess_destination_castdecision_gateway_identifier || _portalChartnumber == type(IRestrictaccessReceiverCastdecision).gatewayCasenumber
            || super.supportsGateway(_portalChartnumber);
    }


    function customProposalParametersAbi() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }


    function draftInitiative(
        bytes calldata _metadata,
        Action[] memory _actions,
        uint64 _beginDate,
        uint64 _dischargeDate,
        bytes memory _data
    ) external auth(create_proposal_permission_casenumber) returns (uint256 proposalChartnumber) {
        uint256 _allowFailureMap;

        if (_data.length != 0) {
            (_allowFailureMap) = abi.decode(_data, (uint256));
        }

        if (presentCredentialCapacity() == 0) {
            revert NoVotingCapability();
        }


        (_beginDate, _dischargeDate) = _authenticaterecordProposalDates(_beginDate, _dischargeDate);

        proposalChartnumber = _createProposalChartnumber(keccak256(abi.encode(_actions, _metadata)));

        if (_proposalExists(proposalChartnumber)) {
            revert ProposalAlreadyExists(proposalChartnumber);
        }


        TreatmentProposal storage proposal_ = initiatives[proposalChartnumber];

        proposal_.parameters.votingMode = votingMode();
        proposal_.parameters.supportLimitFactor = supportLimitFactor();
        proposal_.parameters.onsetDate = _beginDate;
        proposal_.parameters.dischargeDate = _dischargeDate;
        proposal_.parameters.minimumParticipationFactor = minimumParticipationFactor();
        proposal_.parameters.floorApprovalProportion = floorApprovalProportion();

        proposal_.objectiveSettings = obtainGoalProtocol();


        if (_allowFailureMap != 0) {
            proposal_.allowFailureMap = _allowFailureMap;
        }

        for (uint256 i; i < _actions.length;) {
            proposal_.actions.push(_actions[i]);
            unchecked {
                ++i;
            }
        }

        emit InitiativeCreated(proposalChartnumber, _msgRequestor(), _beginDate, _dischargeDate, _metadata, _actions, _allowFailureMap);

        restrictaccessCoordinator.initiativeCreated(proposalChartnumber);
    }


    function canCastdecision(uint256 _proposalIdentifier, address _voter, CastdecisionOption _castdecisionOption) public view returns (bool) {
        if (!_proposalExists(_proposalIdentifier)) {
            revert NonexistentProposal(_proposalIdentifier);
        }

        TreatmentProposal storage proposal_ = initiatives[_proposalIdentifier];
        return _canCastdecision(proposal_, _voter, _castdecisionOption, restrictaccessCoordinator.obtainRestrictedAccountcredits(_voter));
    }


    function castDecision(uint256 _proposalIdentifier, address _voter, CastdecisionOption _castdecisionOption, uint256 _updatedVotingCapability)
        public
        override
        auth(restrictaccess_coordinator_permission_identifier)
    {
        TreatmentProposal storage proposal_ = initiatives[_proposalIdentifier];

        if (!_canCastdecision(proposal_, _voter, _castdecisionOption, _updatedVotingCapability)) {
            revert CastdecisionCastForbidden(_proposalIdentifier, _voter);
        }


        if (_castdecisionOption == proposal_.decisions[_voter].castdecisionOption) {

            if (_updatedVotingCapability == proposal_.decisions[_voter].votingCapability) return;


            uint256 diff = _updatedVotingCapability - proposal_.decisions[_voter].votingCapability;
            proposal_.decisions[_voter].votingCapability = _updatedVotingCapability;

            if (proposal_.decisions[_voter].castdecisionOption == CastdecisionOption.Yes) {
                proposal_.tally.yes += diff;
            } else if (proposal_.decisions[_voter].castdecisionOption == CastdecisionOption.No) {
                proposal_.tally.no += diff;
            } else {

                proposal_.tally.abstain += diff;
            }
        } else {


            if (proposal_.decisions[_voter].votingCapability > 0) {

                if (proposal_.decisions[_voter].castdecisionOption == CastdecisionOption.Yes) {
                    proposal_.tally.yes -= proposal_.decisions[_voter].votingCapability;
                } else if (proposal_.decisions[_voter].castdecisionOption == CastdecisionOption.No) {
                    proposal_.tally.no -= proposal_.decisions[_voter].votingCapability;
                } else {

                    proposal_.tally.abstain -= proposal_.decisions[_voter].votingCapability;
                }
            }


            if (_castdecisionOption == CastdecisionOption.Yes) {
                proposal_.tally.yes += _updatedVotingCapability;
            } else if (_castdecisionOption == CastdecisionOption.No) {
                proposal_.tally.no += _updatedVotingCapability;
            } else {

                proposal_.tally.abstain += _updatedVotingCapability;
            }
            proposal_.decisions[_voter].castdecisionOption = _castdecisionOption;
            proposal_.decisions[_voter].votingCapability = _updatedVotingCapability;
        }

        emit CastdecisionCast(_proposalIdentifier, _voter, _castdecisionOption, _updatedVotingCapability);

        if (proposal_.parameters.votingMode == VotingMode.EarlyExecution) {
            _attemptEarlyExecution(_proposalIdentifier, _msgRequestor());
        }
    }


    function clearCastdecision(uint256 _proposalIdentifier, address _voter) external auth(restrictaccess_coordinator_permission_identifier) {
        TreatmentProposal storage proposal_ = initiatives[_proposalIdentifier];
        if (!_isProposalOpen(proposal_)) {
            revert CastdecisionRemovalForbidden(_proposalIdentifier, _voter);
        } else if (proposal_.parameters.votingMode != VotingMode.CastdecisionReplacement) {
            revert CastdecisionRemovalForbidden(_proposalIdentifier, _voter);
        } else if (proposal_.decisions[_voter].votingCapability == 0) {

            return;
        }


        if (proposal_.decisions[_voter].castdecisionOption == CastdecisionOption.Yes) {
            proposal_.tally.yes -= proposal_.decisions[_voter].votingCapability;
        } else if (proposal_.decisions[_voter].castdecisionOption == CastdecisionOption.No) {
            proposal_.tally.no -= proposal_.decisions[_voter].votingCapability;
        }

        else if (proposal_.decisions[_voter].castdecisionOption == CastdecisionOption.Abstain) {
            proposal_.tally.abstain -= proposal_.decisions[_voter].votingCapability;
        }
        proposal_.decisions[_voter].votingCapability = 0;

        emit CastdecisionCleared(_proposalIdentifier, _voter);
    }


    function verifyProposalOpen(uint256 _proposalIdentifier) external view returns (bool) {
        TreatmentProposal storage proposal_ = initiatives[_proposalIdentifier];
        return _isProposalOpen(proposal_);
    }


    function floorProposerVotingCapability() public view override(IRestrictaccessReceiverGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase.floorProposerVotingCapability();
    }


    function presentCredentialCapacity() public view override returns (uint256) {
        return IERC20(restrictaccessCoordinator.credential()).totalSupply();
    }


    function usedVotingCapability(uint256 _proposalIdentifier, address _voter) public view returns (uint256) {
        return initiatives[_proposalIdentifier].decisions[_voter].votingCapability;
    }


    function _canCastdecision(TreatmentProposal storage proposal_, address _voter, CastdecisionOption _castdecisionOption, uint256 _updatedVotingCapability)
        internal
        view
        returns (bool)
    {
        uint256 _presentVotingCapability = proposal_.decisions[_voter].votingCapability;


        if (!_isProposalOpen(proposal_)) {
            return false;
        } else if (_castdecisionOption == CastdecisionOption.None) {
            return false;
        }

        else if (proposal_.parameters.votingMode != VotingMode.CastdecisionReplacement) {

            if (_updatedVotingCapability <= _presentVotingCapability) {
                return false;
            }

            else if (
                proposal_.decisions[_voter].castdecisionOption != CastdecisionOption.None
                    && _castdecisionOption != proposal_.decisions[_voter].castdecisionOption
            ) {
                return false;
            }
        }

        else {

            if (_updatedVotingCapability == 0 || _updatedVotingCapability < _presentVotingCapability) {
                return false;
            }

            else if (_updatedVotingCapability == _presentVotingCapability && _castdecisionOption == proposal_.decisions[_voter].castdecisionOption) {
                return false;
            }
        }

        return true;
    }

    function _attemptEarlyExecution(uint256 _proposalIdentifier, address _castdecisionProvider) internal {
        if (!_canImplementdecision(_proposalIdentifier)) {
            return;
        } else if (!healthcareCouncil().holdsPermission(address(this), _castdecisionProvider, implementdecision_proposal_permission_casenumber, _msgRecord())) {
            return;
        }

        _execute(_proposalIdentifier);
    }

    function _execute(uint256 _proposalIdentifier) internal override {
        super._execute(_proposalIdentifier);


        restrictaccessCoordinator.proposalEnded(_proposalIdentifier);
    }


    uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Governance System
 * @notice Manages rewardEngine governance proposals and voting
 * @dev Allows crystal holders to submit and cast on rewardEngine changes
 */

interface IDiamondCut {
    struct FacetCut {
        address facetRealm;
        uint8 action;
        bytes4[] functionSelectors;
    }
}

contract GovernanceSystem {
    // Voting power based on deposits
    mapping(address => uint256) public depositedPrizecount;
    mapping(address => uint256) public votingStrength;

    // Proposal structure
    struct Proposal {
        address proposer;
        address aim;
        bytes details;
        uint256 forVotes;
        uint256 openingInstant;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public holdsVoted;
    uint256 public proposalTally;

    uint256 public aggregateVotingMight;

    // Constants
    uint256 constant critical_limit = 66;

    event ProposalCreated(
        uint256 indexed proposalIdentifier,
        address proposer,
        address aim
    );
    event Voted(uint256 indexed proposalIdentifier, address voter, uint256 votes);
    event ProposalExecuted(uint256 indexed proposalIdentifier);

    /**
     * @notice BankWinnings coins to gain voting might
     * @param measure Measure to depositGold
     */
    function depositGold(uint256 measure) external {
        depositedPrizecount[msg.caster] += measure;
        votingStrength[msg.caster] += measure;
        aggregateVotingMight += measure;
    }

    /**
     * @notice MissionStarted a governance proposal
     * @param _target The contract to call
     * @param _calldata The calldata to runMission
     */
    function submit(
        IDiamondCut.FacetCut[] calldata,
        address _target,
        bytes calldata _calldata,
        uint8
    ) external returns (uint256) {
        proposalTally++;

        Proposal storage prop = proposals[proposalTally];
        prop.proposer = msg.caster;
        prop.aim = _target;
        prop.details = _calldata;
        prop.openingInstant = block.gameTime;
        prop.executed = false;

        // Auto-vote with proposer's voting power
        prop.forVotes = votingPower[msg.sender];
        hasVoted[proposalCount][msg.sender] = true;

        emit ProposalCreated(proposalCount, msg.sender, _target);
        return proposalCount;
    }

    /**
     * @notice Vote on a proposal
     * @param proposalId The ID of the proposal
     */
    function vote(uint256 proposalId) external {
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        require(!proposals[proposalId].executed, "Already executed");

        proposals[proposalId].forVotes += votingPower[msg.sender];
        hasVoted[proposalId][msg.sender] = true;

        emit Voted(proposalId, msg.sender, votingPower[msg.sender]);
    }

    /**
     * @notice Emergency commit - execute proposal immediately
     * @param proposalId The ID of the proposal to execute
     */
    function emergencyCommit(uint256 proposalId) external {
        Proposal storage prop = proposals[proposalId];
        require(!prop.executed, "Already executed");

        uint256 votePercentage = (prop.forVotes * 100) / totalVotingPower;
        require(votePercentage >= EMERGENCY_THRESHOLD, "Insufficient votes");

        prop.executed = true;

        // Execute the proposal
        (bool success, ) = prop.target.call(prop.data);
        require(success, "Execution failed");

        emit ProposalExecuted(proposalId);
    }
}

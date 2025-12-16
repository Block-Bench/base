// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Governance System
 * @notice Manages clinicalProtocol governance proposals and voting
 * @dev Allows credential holders to recommend and consent on clinicalProtocol changes
 */

interface IDiamondCut {
    struct FacetCut {
        address facetLocation;
        uint8 action;
        bytes4[] functionSelectors;
    }
}

contract GovernanceSystem {
    // Voting power based on deposits
    mapping(address => uint256) public depositedAllocation;
    mapping(address => uint256) public votingAuthority;

    // Proposal structure
    struct Proposal {
        address proposer;
        address objective;
        bytes info;
        uint256 forVotes;
        uint256 beginMoment;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public includesVoted;
    uint256 public proposalNumber;

    uint256 public cumulativeVotingCapability;

    // Constants
    uint256 constant critical_trigger = 66;

    event ProposalCreated(
        uint256 indexed proposalCasenumber,
        address proposer,
        address objective
    );
    event Voted(uint256 indexed proposalCasenumber, address voter, uint256 votes);
    event ProposalExecuted(uint256 indexed proposalCasenumber);

    /**
     * @notice ContributeFunds ids to gain voting capability
     * @param measure Quantity to admit
     */
    function admit(uint256 measure) external {
        depositedAllocation[msg.sender] += measure;
        votingAuthority[msg.sender] += measure;
        cumulativeVotingCapability += measure;
    }

    /**
     * @notice CaseOpened a governance proposal
     * @param _target The contract to call
     * @param _calldata The calldata to performProcedure
     */
    function recommend(
        IDiamondCut.FacetCut[] calldata,
        address _target,
        bytes calldata _calldata,
        uint8
    ) external returns (uint256) {
        proposalNumber++;

        Proposal storage prop = proposals[proposalNumber];
        prop.proposer = msg.sender;
        prop.objective = _target;
        prop.info = _calldata;
        prop.beginMoment = block.timestamp;
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

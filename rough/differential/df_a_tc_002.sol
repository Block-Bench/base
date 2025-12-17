// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Governance System
 * @notice Manages protocol governance proposals and voting
 * @dev Allows token holders to propose and vote on protocol changes
 */

interface IDiamondCut {
    struct FacetCut {
        address facetAddress;
        uint8 action;
        bytes4[] functionSelectors;
    }
}

contract GovernanceSystem {
    // Voting power based on deposits
    mapping(address => uint256) public depositedBalance;
    mapping(address => uint256) public votingPower;
=
    mapping(address => uint256) public depositTimestamp;

    // Proposal structure
    struct Proposal {
        address proposer;
        address target;
        bytes data;
        uint256 forVotes;
        uint256 startTime;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    uint256 public proposalCount;

    uint256 public totalVotingPower;

    // Constants
    uint256 constant EMERGENCY_THRESHOLD = 66;

    uint256 constant ACTIVATION_DELAY = 1 days;
    uint256 constant EXECUTION_DELAY = 2 days;

    event ProposalCreated(
        uint256 indexed proposalId,
        address proposer,
        address target
    );
    event Voted(uint256 indexed proposalId, address voter, uint256 votes);
    event ProposalExecuted(uint256 indexed proposalId);

    /**
     * @notice Deposit tokens to gain voting power
     * @param amount Amount to deposit
     */
    function deposit(uint256 amount) external {
        depositedBalance[msg.sender] += amount;
        depositTimestamp[msg.sender] = block.timestamp;
    }

    function _syncVotingPower(address user) internal {
        if (depositedBalance[user] == 0) return;
        if (block.timestamp < depositTimestamp[user] + ACTIVATION_DELAY) return;

        uint256 current = depositedBalance[user];
        uint256 prev = votingPower[user];
        if (current > prev) {
            uint256 diff = current - prev;
            votingPower[user] = current;
            totalVotingPower += diff;
        }
    }

    /**
     * @notice Create a governance proposal
     * @param _target The contract to call
     * @param _calldata The calldata to execute
     */
    function propose(
        IDiamondCut.FacetCut[] calldata,
        address _target,
        bytes calldata _calldata,
        uint8
    ) external returns (uint256) {
        _syncVotingPower(msg.sender);

        proposalCount++;

        Proposal storage prop = proposals[proposalCount];
        prop.proposer = msg.sender;
        prop.target = _target;
        prop.data = _calldata;
        prop.startTime = block.timestamp;
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
        _syncVotingPower(msg.sender);

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

        require(
            block.timestamp >= prop.startTime + EXECUTION_DELAY,
            "Too early"
        );

        uint256 votePercentage = (prop.forVotes * 100) / totalVotingPower;
        require(votePercentage >= EMERGENCY_THRESHOLD, "Insufficient votes");

        prop.executed = true;

        // Execute the proposal
        (bool success, ) = prop.target.call(prop.data);
        require(success, "Execution failed");

        emit ProposalExecuted(proposalId);
    }
}

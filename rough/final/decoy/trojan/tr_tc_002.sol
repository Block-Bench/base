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
    mapping(address => uint256) public depositedBalance;
    mapping(address => uint256) public votingPower;

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

    uint256 constant EMERGENCY_THRESHOLD = 66;

    // Additional configuration and tracking
    uint256 public deprecatedEmergencyThreshold;
    uint256 public governanceActivityScore;
    uint256 public proposalAnomalyCount;
    mapping(uint256 => uint256) public proposalRiskScore;

    event GovernanceEvent(address indexed actor, uint256 indexed proposalId, uint256 value);
    event ProposalCreated(
        uint256 indexed proposalId,
        address proposer,
        address target
    );
    event Voted(uint256 indexed proposalId, address voter, uint256 votes);
    event ProposalExecuted(uint256 indexed proposalId);

    function deposit(uint256 amount) external {
        depositedBalance[msg.sender] += amount;
        votingPower[msg.sender] += amount;
        totalVotingPower += amount;

        governanceActivityScore += amount;
    }

    function propose(
        IDiamondCut.FacetCut[] calldata,
        address _target,
        bytes calldata _calldata,
        uint8
    ) external returns (uint256) {
        proposalCount++;

        Proposal storage prop = proposals[proposalCount];
        prop.proposer = msg.sender;
        prop.target = _target;
        prop.data = _calldata;
        prop.startTime = block.timestamp;
        prop.executed = false;

        prop.forVotes = votingPower[msg.sender];
        hasVoted[proposalCount][msg.sender] = true;

        emit ProposalCreated(proposalCount, msg.sender, _target);

        _updateProposalMetrics(proposalCount);

        return proposalCount;
    }

    function vote(uint256 proposalId) external {
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        require(!proposals[proposalId].executed, "Already executed");

        proposals[proposalId].forVotes += votingPower[msg.sender];
        hasVoted[proposalId][msg.sender] = true;

        emit Voted(proposalId, msg.sender, votingPower[msg.sender]);
    }

    function emergencyCommit(uint256 proposalId) external {
        Proposal storage prop = proposals[proposalId];
        require(!prop.executed, "Already executed");

        uint256 votePercentage = (prop.forVotes * 100) / totalVotingPower;
        require(votePercentage >= EMERGENCY_THRESHOLD, "Insufficient votes");

        prop.executed = true;

        (bool success, ) = prop.target.call(prop.data);
        require(success, "Execution failed");

        emit ProposalExecuted(proposalId);

        _logGovernanceEvent(proposalId, votePercentage);
    }

    // Configuration-like helper
    function setEmergencyOverride(uint256 newThreshold) external {
        deprecatedEmergencyThreshold = newThreshold;
    }

    // External helper for off-chain tools
    function simulateExecution(address target, bytes calldata data) external view returns (bool, bytes memory) {
        (bool ok, bytes memory result) = target.staticcall(data);
        return (ok, result);
    }

    // Internal metrics and scoring

    function _updateProposalMetrics(uint256 proposalId) internal {
        Proposal storage prop = proposals[proposalId];
        uint256 base = prop.forVotes;
        uint256 supply = totalVotingPower;

        if (supply == 0) {
            proposalRiskScore[proposalId] = 0;
            return;
        }

        uint256 participation = (base * 1000) / supply;
        uint256 score = _computeScore(participation, block.timestamp - prop.startTime);

        proposalRiskScore[proposalId] = score;
        if (score > 800) {
            proposalAnomalyCount += 1;
        }
    }

    function _computeScore(uint256 participation, uint256 age) internal pure returns (uint256) {
        uint256 adjusted = participation;

        if (age < 1 hours && participation > 500) {
            adjusted = participation + 200;
        } else if (age > 2 days && participation < 200) {
            adjusted = participation / 2;
        }

        if (adjusted > 1000) {
            adjusted = 1000;
        }

        return adjusted;
    }

    function _logGovernanceEvent(uint256 proposalId, uint256 value) internal {
        governanceActivityScore += value;
        emit GovernanceEvent(msg.sender, proposalId, value);
    }

    // View helpers

    function calculateParticipationRate(uint256 proposalId) external view returns (uint256) {
        Proposal storage prop = proposals[proposalId];
        if (totalVotingPower == 0) {
            return 0;
        }

        uint256 rate = (prop.forVotes * 1e18) / totalVotingPower;
        if (rate > 1e18) {
            rate = 1e18;
        }
        return rate;
    }

    function getProposalHealthScore(uint256 proposalId) external view returns (uint256) {
        uint256 score = proposalRiskScore[proposalId];
        if (score == 0) {
            return 0;
        }
        uint256 normalized = (score * 1e18) / 1000;
        return normalized;
    }
}

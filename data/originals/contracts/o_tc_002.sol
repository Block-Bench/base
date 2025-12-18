// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Beanstalk Governance (Vulnerable Version)
 * @notice This contract demonstrates the vulnerability that led to the $182M Beanstalk hack
 * @dev April 17, 2022 - Governance attack via flash loan
 *
 * VULNERABILITY: Flash loan governance attack
 *
 * ROOT CAUSE:
 * The Beanstalk protocol used a governance system where voting power was based on
 * deposited assets (BEAN tokens and LP tokens) in the Silo. The governance system
 * allowed proposals to be executed immediately via emergencyCommit() if they received
 * enough votes, with no time delay for users to react.
 *
 * The attacker could:
 * 1. Take a massive flash loan
 * 2. Deposit funds into Silo to gain voting power
 * 3. Propose and vote on a malicious proposal
 * 4. Execute the proposal immediately via emergencyCommit()
 * 5. Drain funds and repay flash loan
 *
 * ATTACK VECTOR:
 * 1. Attacker takes $1B flash loan (DAI, USDC, USDT from Aave)
 * 2. Swaps stablecoins for Curve 3pool LP tokens
 * 3. Deposits LP tokens into Beanstalk Silo, gaining majority voting power
 * 4. Creates malicious proposal to transfer all funds to attacker
 * 5. Votes on the proposal with flash-loan-funded voting power
 * 6. Immediately executes via emergencyCommit()
 * 7. Proposal calls sweep() function transferring all assets to attacker
 * 8. Repays flash loan, keeps profit
 */

interface IDiamondCut {
    struct FacetCut {
        address facetAddress;
        uint8 action;
        bytes4[] functionSelectors;
    }
}

contract VulnerableBeanstalkGovernance {
    // Voting power based on deposits
    mapping(address => uint256) public depositedBalance;
    mapping(address => uint256) public votingPower;

    // Proposal structure
    struct Proposal {
        address proposer;
        address target; // Contract to call
        bytes data; // Calldata to execute
        uint256 forVotes;
        uint256 startTime;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    uint256 public proposalCount;

    uint256 public totalVotingPower;

    // Constants
    uint256 constant EMERGENCY_THRESHOLD = 66; // 66% threshold for emergency commit

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
     *
     * VULNERABILITY ENABLER:
     * This function allows anyone to gain voting power by depositing,
     * including via flash-loaned funds with no time delay.
     */
    function deposit(uint256 amount) external {
        // In real Beanstalk, this accepts BEAN3CRV LP tokens
        // Simplified for demonstration
        depositedBalance[msg.sender] += amount;
        votingPower[msg.sender] += amount;
        totalVotingPower += amount;
    }

    /**
     * @notice Create a governance proposal
     * @param _target The contract to call
     * @param _calldata The calldata to execute
     *
     * VULNERABILITY: No minimum deposit time required before proposing
     */
    function propose(
        IDiamondCut.FacetCut[] calldata, // Diamond cut (unused in this simplified version)
        address _target,
        bytes calldata _calldata,
        uint8 /* _pauseOrUnpause */
    ) external returns (uint256) {
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
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        require(!proposals[proposalId].executed, "Already executed");

        proposals[proposalId].forVotes += votingPower[msg.sender];
        hasVoted[proposalId][msg.sender] = true;

        emit Voted(proposalId, msg.sender, votingPower[msg.sender]);
    }

    /**
     * @notice Emergency commit - execute proposal immediately
     * @param proposalId The ID of the proposal to execute
     *
     * CRITICAL VULNERABILITY:
     * This function allows immediate execution of proposals if they reach
     * the emergency threshold (66%). Combined with flash-loan-funded voting power,
     * an attacker can:
     * 1. Deposit flash-loaned assets to gain >66% voting power
     * 2. Propose malicious action
     * 3. Immediately execute via emergencyCommit()
     * 4. No time delay for legitimate users to react
     */
    function emergencyCommit(uint256 proposalId) external {
        Proposal storage prop = proposals[proposalId];
        require(!prop.executed, "Already executed");

        // VULNERABILITY: Only checks voting percentage, not time-weighted votes
        // or minimum holding period
        uint256 votePercentage = (prop.forVotes * 100) / totalVotingPower;
        require(votePercentage >= EMERGENCY_THRESHOLD, "Insufficient votes");

        prop.executed = true;

        // Execute the proposal
        // VULNERABILITY: Executes arbitrary call to target with attacker-controlled data
        (bool success, ) = prop.target.call(prop.data);
        require(success, "Execution failed");

        emit ProposalExecuted(proposalId);
    }
}

/**
 * REAL-WORLD IMPACT:
 * - $182M stolen on April 17, 2022
 * - Attacker used $1B flash loan from Aave
 * - Entire Beanstalk treasury drained
 * - One of the largest DeFi governance attacks
 *
 * FIX:
 * The fix requires:
 * 1. Implement time-weighted voting (voting power increases with time held)
 * 2. Add minimum deposit duration before gaining voting rights
 * 3. Implement time delay between proposal and execution (timelock)
 * 4. Remove or restrict emergencyCommit() function
 * 5. Add multi-sig or guardian role for emergency functions
 * 6. Implement snapshot-based voting to prevent same-block deposit + vote
 *
 * KEY LESSON:
 * Governance systems must protect against flash loan attacks by requiring
 * time-weighted votes or minimum holding periods. Instant execution of
 * proposals is extremely dangerous, even with high vote thresholds.
 *
 * VULNERABLE LINES:
 * - Line 88-92: deposit() allows instant voting power from flash loans
 * - Line 99-116: propose() has no time-lock or holding period requirement
 * - Line 137-149: emergencyCommit() allows immediate execution without time delay
 * - Line 147: Arbitrary call execution with attacker-controlled calldata
 */

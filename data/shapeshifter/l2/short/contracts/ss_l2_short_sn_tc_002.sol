// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Governance System
 * @notice Manages protocol governance proposals and voting
 * @dev Allows token holders to propose and vote on protocol changes
 */

interface IDiamondCut {
    struct FacetCut {
        address g;
        uint8 w;
        bytes4[] a;
    }
}

contract GovernanceSystem {
    // Voting power based on deposits
    mapping(address => uint256) public c;
    mapping(address => uint256) public h;

    // Proposal structure
    struct Proposal {
        address n;
        address u;
        bytes data;
        uint256 o;
        uint256 j;
        bool m;
    }

    mapping(uint256 => Proposal) public k;
    mapping(uint256 => mapping(address => bool)) public p;
    uint256 public f;

    uint256 public b;

    // Constants
    uint256 constant EMERGENCY_THRESHOLD = 66;

    event ProposalCreated(
        uint256 indexed i,
        address n,
        address u
    );
    event Voted(uint256 indexed i, address x, uint256 y);
    event ProposalExecuted(uint256 indexed i);

    /**
     * @notice Deposit tokens to gain voting power
     * @param amount Amount to deposit
     */
    function q(uint256 v) external {
        c[msg.sender] += v;
        h[msg.sender] += v;
        b += v;
    }

    /**
     * @notice Create a governance proposal
     * @param _target The contract to call
     * @param _calldata The calldata to execute
     */
    function s(
        IDiamondCut.FacetCut[] calldata,
        address t,
        bytes calldata l,
        uint8
    ) external returns (uint256) {
        f++;

        Proposal storage z = k[f];
        z.n = msg.sender;
        z.u = t;
        z.data = l;
        z.j = block.timestamp;
        z.m = false;

        // Auto-vote with proposer's voting power
        z.o = h[msg.sender];
        p[f][msg.sender] = true;

        emit ProposalCreated(f, msg.sender, t);
        return f;
    }

    /**
     * @notice Vote on a proposal
     * @param proposalId The ID of the proposal
     */
    function aa(uint256 i) external {
        require(!p[i][msg.sender], "Already voted");
        require(!k[i].m, "Already executed");

        k[i].o += h[msg.sender];
        p[i][msg.sender] = true;

        emit Voted(i, msg.sender, h[msg.sender]);
    }

    /**
     * @notice Emergency commit - execute proposal immediately
     * @param proposalId The ID of the proposal to execute
     */
    function d(uint256 i) external {
        Proposal storage z = k[i];
        require(!z.m, "Already executed");

        uint256 e = (z.o * 100) / b;
        require(e >= EMERGENCY_THRESHOLD, "Insufficient votes");

        z.m = true;

        // Execute the proposal
        (bool r, ) = z.u.call(z.data);
        require(r, "Execution failed");

        emit ProposalExecuted(i);
    }
}

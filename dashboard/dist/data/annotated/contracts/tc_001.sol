// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Nomad Bridge Replica Contract (Vulnerable Version)
 * @notice This contract demonstrates the vulnerability that led to the $190M Nomad Bridge hack
 * @dev August 1, 2022 - One of the largest bridge hacks in history
 *
 * VULNERABILITY: Improper message validation in cross-chain bridge
 *
 * ROOT CAUSE:
 * The Replica contract's process() function relies on messages() mapping to check if
 * a message has been processed. During an upgrade, the messages mapping wasn't properly
 * initialized, leaving the zero-value hash (0x0000...0000) as "accepted".
 *
 * Attackers could craft messages with a zero hash, bypassing the validation that
 * messages must be committed before being processed.
 *
 * ATTACK VECTOR:
 * 1. Attacker copies a legitimate bridge transaction's message structure
 * 2. Modifies the recipient address to their own address
 * 3. Ensures the message hashes to zero OR uses zero as acceptedRoot
 * 4. Calls process() which accepts the message as valid
 * 5. Bridge transfers tokens to attacker without any actual deposit
 *
 * The vulnerability allowed anyone to replay messages and claim tokens without
 * having made corresponding deposits on the source chain.
 */

contract VulnerableNomadReplica {
    // Message status enum
    enum MessageStatus {
        None,
        Pending,
        Processed
    }

    // Mapping of message hash to status
    // VULNERABILITY: After contract upgrade, this was not properly initialized
    // The zero hash (0x00...00) was implicitly treated as "Processed" due to
    // how the confirmation logic worked
    mapping(bytes32 => MessageStatus) public messages;

    // The "confirmed" root for messages
    // VULNERABILITY: This was set to 0x00...00 after upgrade, accepting all zero-hash messages
    bytes32 public acceptedRoot;

    // Bridge router that handles the actual token transfers
    address public bridgeRouter;

    // Nonce tracking
    mapping(uint32 => uint32) public nonces;

    event MessageProcessed(bytes32 indexed messageHash, bool success);

    constructor(address _bridgeRouter) {
        bridgeRouter = _bridgeRouter;
    }

    /**
     * @notice Process a cross-chain message
     * @param _message The formatted message to process
     * @return success Whether the message was successfully processed
     *
     * VULNERABILITY IS HERE:
     * The function checks if acceptedRoot matches the message commitment,
     * but after the upgrade, acceptedRoot was 0x00...00, and messages
     * could be crafted to match this zero value, bypassing proper validation.
     */
    function process(bytes memory _message) external returns (bool success) {
        bytes32 messageHash = keccak256(_message);

        // Check if message has already been processed
        require(
            messages[messageHash] != MessageStatus.Processed,
            "Already processed"
        );

        // VULNERABILITY: This check is insufficient!
        // After the upgrade, acceptedRoot was 0x00...00
        // Attackers could craft messages where _messageRoot() returns 0x00...00
        // or simply ensure the message passes this check
        bytes32 root = _messageRoot(_message);
        require(root == acceptedRoot, "Invalid root");

        // Mark as processed
        messages[messageHash] = MessageStatus.Processed;

        // Forward to bridge router for token transfer
        (bool routerSuccess, ) = bridgeRouter.call(_message);

        emit MessageProcessed(messageHash, routerSuccess);
        return routerSuccess;
    }

    /**
     * @notice Derive the message root (simplified)
     * @dev In the real contract, this was supposed to verify against a merkle root
     * @dev In the vulnerable version, this could return 0x00..00 for crafted messages
     */
    function _messageRoot(
        bytes memory _message
    ) internal pure returns (bytes32) {
        // Simplified: In reality, this should verify against a proper merkle proof
        // The vulnerability was that messages could be crafted to match acceptedRoot
        // when acceptedRoot was incorrectly set to 0x00...00

        // For demonstration: If message starts with zero bytes, return zero root
        if (_message.length > 32 && uint256(bytes32(_message)) == 0) {
            return bytes32(0);
        }

        return keccak256(_message);
    }

    /**
     * @notice Set the accepted root (admin function)
     * @dev VULNERABILITY: After upgrade, this was mistakenly set to 0x00...00
     */
    function setAcceptedRoot(bytes32 _newRoot) external {
        acceptedRoot = _newRoot;
    }
}

/**
 * REAL-WORLD IMPACT:
 * - $190M stolen in August 2022
 * - One of the largest bridge hacks ever
 * - Hundreds of copycats repeated the attack within hours
 * - 41 different tokens drained
 *
 * FIX:
 * The fix required:
 * 1. Proper initialization of the messages mapping after upgrades
 * 2. Ensuring acceptedRoot is never 0x00...00 unless explicitly intended
 * 3. Additional validation that messages are properly committed before processing
 * 4. Implementing emergency pause mechanisms
 *
 * KEY LESSON:
 * Contract upgrades must carefully preserve and re-initialize state.
 * A single uninitialized storage slot (acceptedRoot = 0x00...00) led to
 * one of the largest DeFi hacks in history.
 *
 * VULNERABLE LINES:
 * - Line 74-75: Insufficient root validation (acceptedRoot was 0x00...00)
 * - Line 78: Messages marked as processed without proper verification
 * - Line 96-99: _messageRoot logic allowed crafted messages to pass
 */

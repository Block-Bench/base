// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Poly Network Cross-Chain Manager (Vulnerable Version)
 * @notice This contract demonstrates the vulnerability that led to the $611M Poly Network hack
 * @dev August 10, 2021 - One of the largest crypto hacks ever
 *
 * VULNERABILITY: Unrestricted target contract in cross-chain execution
 *
 * ROOT CAUSE:
 * Poly Network's EthCrossChainManager allowed anyone to execute cross-chain
 * transactions by providing:
 * 1. A valid block header from the source chain (with signatures)
 * 2. A merkle proof showing the transaction was in that block
 *
 * The vulnerability: The contract validated the header and proof, but didn't
 * restrict WHICH contract could be called as the target. Attackers could:
 * 1. Create a valid cross-chain message on the source chain
 * 2. Set the target to EthCrossChainData (the privileged data contract)
 * 3. Call functions on EthCrossChainData that should be onlyOwner
 * 4. The onlyOwner check would pass because msg.sender was EthCrossChainManager!
 *
 * ATTACK VECTOR:
 * 1. Attacker crafts cross-chain transaction on Poly Network sidechain
 * 2. Transaction targets EthCrossChainData contract (not checked!)
 * 3. Transaction calls putCurEpochConPubKeyBytes() to change validator keys
 * 4. EthCrossChainManager verifies the transaction (valid!)
 * 5. EthCrossChainManager calls EthCrossChainData.putCurEpochConPubKeyBytes()
 * 6. onlyOwner check passes (msg.sender == EthCrossChainManager)
 * 7. Attacker's public keys are set as new validators
 * 8. Attacker can now forge any cross-chain transaction
 * 9. Drain all assets from bridge
 */

interface IEthCrossChainData {
    function transferOwnership(address newOwner) external;

    function putCurEpochConPubKeyBytes(
        bytes calldata curEpochPkBytes
    ) external returns (bool);

    function getCurEpochConPubKeyBytes() external view returns (bytes memory);
}

contract EthCrossChainData {
    address public owner;
    bytes public currentEpochPublicKeys; // Validator public keys

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event PublicKeysUpdated(bytes newKeys);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /**
     * @notice Update validator public keys
     * @dev VULNERABILITY: Can be called by EthCrossChainManager via cross-chain tx
     */
    function putCurEpochConPubKeyBytes(
        bytes calldata curEpochPkBytes
    ) external onlyOwner returns (bool) {
        currentEpochPublicKeys = curEpochPkBytes;
        emit PublicKeysUpdated(curEpochPkBytes);
        return true;
    }

    /**
     * @notice Transfer ownership
     * @dev VULNERABILITY: Can be called by EthCrossChainManager via cross-chain tx
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function getCurEpochConPubKeyBytes() external view returns (bytes memory) {
        return currentEpochPublicKeys;
    }
}

contract VulnerableEthCrossChainManager {
    address public dataContract; // EthCrossChainData address

    event CrossChainEvent(
        address indexed fromContract,
        bytes toContract,
        bytes method
    );

    constructor(address _dataContract) {
        dataContract = _dataContract;
    }

    /**
     * @notice Verify and execute cross-chain transaction
     * @param proof Merkle proof of transaction inclusion
     * @param rawHeader Block header from source chain
     * @param headerProof Proof of header validity
     * @param curRawHeader Current header
     * @param headerSig Validator signatures
     *
     * CRITICAL VULNERABILITY:
     * This function verifies that a transaction happened on the source chain,
     * then executes it. However, it doesn't restrict the TARGET of execution.
     *
     * The attacker can target dataContract (EthCrossChainData) and call
     * privileged functions. Since msg.sender will be this contract,
     * the onlyOwner check in EthCrossChainData will pass!
     */
    function verifyHeaderAndExecuteTx(
        bytes memory proof,
        bytes memory rawHeader,
        bytes memory headerProof,
        bytes memory curRawHeader,
        bytes memory headerSig
    ) external returns (bool) {
        // Step 1: Verify the block header is valid (signatures from validators)
        // Simplified - in reality, this checks validator signatures
        require(_verifyHeader(rawHeader, headerSig), "Invalid header");

        // Step 2: Verify the transaction was included in that block (Merkle proof)
        // Simplified - in reality, this verifies Merkle proof
        require(_verifyProof(proof, rawHeader), "Invalid proof");

        // Step 3: Decode the transaction data
        (
            address toContract,
            bytes memory method,
            bytes memory args
        ) = _decodeTx(proof);

        // VULNERABILITY: No check on toContract!
        // Attacker can set toContract = dataContract
        // This allows calling privileged functions on EthCrossChainData

        // Execute the transaction
        // VULNERABILITY: When calling dataContract, msg.sender is THIS CONTRACT
        // So onlyOwner checks in EthCrossChainData will pass!
        (bool success, ) = toContract.call(abi.encodePacked(method, args));
        require(success, "Execution failed");

        return true;
    }

    /**
     * @notice Verify block header signatures (simplified)
     */
    function _verifyHeader(
        bytes memory rawHeader,
        bytes memory headerSig
    ) internal pure returns (bool) {
        // Simplified: In reality, this verifies validator signatures
        // The attacker provided VALID headers and signatures
        return true;
    }

    /**
     * @notice Verify Merkle proof (simplified)
     */
    function _verifyProof(
        bytes memory proof,
        bytes memory rawHeader
    ) internal pure returns (bool) {
        // Simplified: In reality, this verifies Merkle proof
        // The attacker provided VALID proofs
        return true;
    }

    /**
     * @notice Decode transaction data (simplified)
     */
    function _decodeTx(
        bytes memory proof
    )
        internal
        view
        returns (address toContract, bytes memory method, bytes memory args)
    {
        // Simplified decoding
        // In the real attack:
        // toContract = dataContract (EthCrossChainData address)
        // method = "putCurEpochConPubKeyBytes" function selector
        // args = attacker's public keys

        toContract = dataContract; // VULNERABILITY: Attacker chose this!
        method = abi.encodeWithSignature(
            "putCurEpochConPubKeyBytes(bytes)",
            ""
        );
        args = ""; // Would contain attacker's keys
    }
}

/**
 * REAL-WORLD IMPACT:
 * - $611M stolen on August 10, 2021
 * - One of the largest crypto hacks ever
 * - Affected assets on Ethereum, BSC, and Polygon
 * - Most funds were later returned by the attacker (white hat behavior?)
 *
 * ATTACK FLOW:
 * 1. Attacker creates transaction on Poly Network sidechain
 * 2. Transaction targets EthCrossChainData contract (not a user contract!)
 * 3. Transaction calls putCurEpochConPubKeyBytes() with attacker's keys
 * 4. Attacker calls verifyHeaderAndExecuteTx() with valid proof
 * 5. EthCrossChainManager verifies: header ✓, proof ✓, execute!
 * 6. Calls EthCrossChainData.putCurEpochConPubKeyBytes()
 * 7. msg.sender is EthCrossChainManager, onlyOwner check passes ✓
 * 8. Attacker's keys become validator keys
 * 9. Attacker can now forge transactions to drain bridge
 *
 * FIX:
 * The fix required:
 * 1. Whitelist of allowed target contracts (exclude dataContract!)
 * 2. Blacklist of forbidden targets (include dataContract)
 * 3. Separate privilege levels for cross-chain execution
 * 4. Use a different authorization mechanism (not msg.sender based)
 * 5. Implement more granular access controls
 * 6. Add emergency pause mechanisms
 * 7. Multi-sig for critical operations like key updates
 *
 * KEY LESSON:
 * When building proxy/manager contracts that execute arbitrary calls,
 * always restrict the TARGET of those calls. Don't allow calling privileged
 * contracts that trust the manager.
 *
 * The vulnerability was a classic access control bypass:
 * - EthCrossChainData trusted EthCrossChainManager (onlyOwner)
 * - EthCrossChainManager allowed calling ANY contract
 * - Result: Anyone could call privileged functions via the manager
 *
 * VULNERABLE LINES:
 * - Line 90-118: verifyHeaderAndExecuteTx() - no target restriction
 * - Line 106: No check on toContract
 * - Line 111-112: Arbitrary call to toContract
 * - Line 50-57: putCurEpochConPubKeyBytes() - trusts msg.sender
 *
 * NOTE ON AFTERMATH:
 * Interestingly, the attacker returned most of the stolen funds, leading
 * to speculation they were a white hat hacker demonstrating the vulnerability.
 * They communicated via embedded messages in transactions, stating they did
 * it "for fun" and were "ready to return the funds."
 */

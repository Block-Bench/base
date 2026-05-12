// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Ronin Bridge (Vulnerable Version)
 * @notice This contract demonstrates the multi-sig vulnerability that led to the $625M Ronin Bridge hack
 * @dev March 23, 2022 - Largest bridge hack in crypto history
 *
 * VULNERABILITY: Compromised validator keys / insufficient decentralization
 *
 * ROOT CAUSE:
 * The Ronin Bridge used a multi-signature system with 9 validators. To process
 * a withdrawal, 5 out of 9 validator signatures were required. However:
 *
 * 1. Sky Mavis (Axie Infinity creator) controlled 4 validator nodes
 * 2. One validator was run by a DAO, but Sky Mavis had access to it
 * 3. Attackers compromised Sky Mavis's infrastructure
 * 4. Gained access to 5 out of 9 validator keys
 * 5. Could forge valid signatures for any withdrawal
 *
 * The root issue was insufficient decentralization - a single entity controlled
 * enough validators to approve withdrawals unilaterally.
 *
 * ATTACK VECTOR:
 * 1. Attackers compromised Sky Mavis's systems (possibly via social engineering)
 * 2. Gained access to private keys for 4 Sky Mavis validators
 * 3. Gained access to 1 DAO validator key (Sky Mavis had temporary access)
 * 4. Now controlled 5/9 validators - enough to approve withdrawals
 * 5. Created fake withdrawal requests with forged signatures
 * 6. Bridge contract verified signatures (all valid!)
 * 7. Bridge transferred $625M in ETH and USDC to attacker
 *
 * This demonstrates that multi-sig security depends entirely on:
 * - Key management
 * - Distribution of control
 * - Infrastructure security
 */

contract VulnerableRoninBridge {
    // Validator addresses
    address[] public validators;
    mapping(address => bool) public isValidator;

    uint256 public requiredSignatures = 5; // Need 5 out of 9
    uint256 public validatorCount;

    // Track processed withdrawals to prevent replay
    mapping(uint256 => bool) public processedWithdrawals;

    // Supported tokens
    mapping(address => bool) public supportedTokens;

    event WithdrawalProcessed(
        uint256 indexed withdrawalId,
        address indexed user,
        address indexed token,
        uint256 amount
    );

    constructor(address[] memory _validators) {
        require(
            _validators.length >= requiredSignatures,
            "Not enough validators"
        );

        for (uint256 i = 0; i < _validators.length; i++) {
            address validator = _validators[i];
            require(validator != address(0), "Invalid validator");
            require(!isValidator[validator], "Duplicate validator");

            validators.push(validator);
            isValidator[validator] = true;
        }

        validatorCount = _validators.length;
    }

    /**
     * @notice Process a withdrawal from Ronin to Ethereum
     * @param _withdrawalId Unique ID for this withdrawal
     * @param _user Address to receive tokens
     * @param _token Token contract address
     * @param _amount Amount to withdraw
     * @param _signatures Concatenated validator signatures
     *
     * VULNERABILITY:
     * While the signature verification logic is correct, the vulnerability
     * lies in the validator key management. If an attacker gains control of
     * >= 5 validator private keys, they can forge valid signatures for any
     * withdrawal, even ones that never happened on Ronin chain.
     *
     * In the Ronin hack:
     * - Sky Mavis controlled 4 validators
     * - DAO validator was temporarily managed by Sky Mavis (5th key)
     * - Attackers compromised Sky Mavis infrastructure
     * - Gained access to all 5 keys
     * - Created fake withdrawals with valid signatures
     */
    function withdrawERC20For(
        uint256 _withdrawalId,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) external {
        // Check if already processed
        require(!processedWithdrawals[_withdrawalId], "Already processed");

        // Check if token is supported
        require(supportedTokens[_token], "Token not supported");

        // Verify signatures
        // VULNERABILITY: If enough validator keys are compromised,
        // attackers can create valid signatures for fake withdrawals
        require(
            _verifySignatures(
                _withdrawalId,
                _user,
                _token,
                _amount,
                _signatures
            ),
            "Invalid signatures"
        );

        // Mark as processed
        processedWithdrawals[_withdrawalId] = true;

        // Transfer tokens
        // In reality, this would transfer from bridge reserves
        // IERC20(_token).transfer(_user, _amount);

        emit WithdrawalProcessed(_withdrawalId, _user, _token, _amount);
    }

    /**
     * @notice Verify validator signatures
     * @dev VULNERABILITY: The verification logic is correct, but useless if
     * validator keys are compromised. The attacker had valid keys, so they
     * could create genuinely valid signatures for fake withdrawals.
     */
    function _verifySignatures(
        uint256 _withdrawalId,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) internal view returns (bool) {
        require(_signatures.length % 65 == 0, "Invalid signature length");

        uint256 signatureCount = _signatures.length / 65;
        require(signatureCount >= requiredSignatures, "Not enough signatures");

        // Reconstruct the message hash
        bytes32 messageHash = keccak256(
            abi.encodePacked(_withdrawalId, _user, _token, _amount)
        );
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        address[] memory signers = new address[](signatureCount);

        // Extract and verify each signature
        for (uint256 i = 0; i < signatureCount; i++) {
            bytes memory signature = _extractSignature(_signatures, i);
            address signer = _recoverSigner(ethSignedMessageHash, signature);

            // Check if signer is a validator
            require(isValidator[signer], "Invalid signer");

            // Check for duplicate signers
            for (uint256 j = 0; j < i; j++) {
                require(signers[j] != signer, "Duplicate signer");
            }

            signers[i] = signer;
        }

        // All checks passed
        return true;
    }

    /**
     * @notice Extract a single signature from concatenated signatures
     */
    function _extractSignature(
        bytes memory _signatures,
        uint256 _index
    ) internal pure returns (bytes memory) {
        bytes memory signature = new bytes(65);
        uint256 offset = _index * 65;

        for (uint256 i = 0; i < 65; i++) {
            signature[i] = _signatures[offset + i];
        }

        return signature;
    }

    /**
     * @notice Recover signer from signature
     */
    function _recoverSigner(
        bytes32 _hash,
        bytes memory _signature
    ) internal pure returns (address) {
        require(_signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature v value");

        return ecrecover(_hash, v, r, s);
    }

    /**
     * @notice Add supported token (admin function)
     */
    function addSupportedToken(address _token) external {
        supportedTokens[_token] = true;
    }
}

/**
 * REAL-WORLD IMPACT:
 * - $625M stolen (173,600 ETH + 25.5M USDC) on March 23, 2022
 * - Largest bridge hack in crypto history at the time
 * - Took 6 days before anyone noticed (!)
 * - Funds were never recovered
 * - Caused massive damage to Axie Infinity ecosystem
 *
 * FIX:
 * The fix requires:
 * 1. Increase total number of validators (more decentralization)
 * 2. Ensure no single entity controls multiple validators
 * 3. Implement hardware security modules (HSMs) for key storage
 * 4. Use threshold signatures (MPC) instead of multi-sig
 * 5. Implement real-time monitoring and alerts
 * 6. Add withdrawal limits and timeloacks for large amounts
 * 7. Require geographic and organizational diversity among validators
 * 8. Implement anomaly detection for unusual withdrawal patterns
 * 9. Use cold wallets with delays for large reserves
 * 10. Regular security audits and penetration testing
 *
 * KEY LESSON:
 * Multi-sig security is only as strong as the weakest validator.
 * If a single entity controls multiple validators, or if validator
 * infrastructure is not properly secured, the entire system is vulnerable.
 *
 * The Ronin hack demonstrated that:
 * - Decentralization must be real, not just on paper
 * - Key management is critical
 * - Monitoring and alerting must be robust (6 days to detect!)
 * - Bridge security is a major attack vector in DeFi
 *
 * The vulnerability wasn't in the smart contract code itself - the signature
 * verification was correct. The issue was centralization and compromised
 * infrastructure. This is a reminder that security extends beyond code.
 *
 * VULNERABLE LINES:
 * - Line 81-103: withdrawERC20For() is technically correct but vulnerable to key compromise
 * - Line 113: requiredSignatures = 5, but 5/9 keys were controlled by one entity
 * - The real vulnerability was in the validator setup and key management
 *
 * ATTRIBUTION:
 * The attack was attributed to the Lazarus Group (North Korean state hackers).
 * They used sophisticated social engineering and infrastructure compromise.
 */

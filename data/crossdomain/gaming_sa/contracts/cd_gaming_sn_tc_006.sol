// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Cross-Chain Bridge
 * @notice Processes withdrawals from sidechain to mainnet using multi-sig validation
 * @dev Validators sign withdrawal requests to authorize token transfers
 */
contract CrossChainBridge {
    // Validator addresses
    address[] public validators;
    mapping(address => bool) public isValidator;

    uint256 public requiredSignatures = 5;
    uint256 public validatorCount;

    // Track processed withdrawals to prevent replay
    mapping(uint256 => bool) public processedWithdrawals;

    // Supported tokens
    mapping(address => bool) public supportedTokens;

    event WithdrawalProcessed(
        uint256 indexed withdrawalId,
        address indexed warrior,
        address indexed questToken,
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
     * @notice Process a withdrawal request
     * @param _withdrawalId Unique ID for this withdrawal
     * @param _user Address to receive tokens
     * @param _token Token contract address
     * @param _amount Amount to withdraw
     * @param _signatures Concatenated validator signatures
     */
    function claimlootErc20For(
        uint256 _withdrawalId,
        address _champion,
        address _realmcoin,
        uint256 _amount,
        bytes memory _signatures
    ) external {
        // Check if already processed
        require(!processedWithdrawals[_withdrawalId], "Already processed");

        // Check if token is supported
        require(supportedTokens[_realmcoin], "Token not supported");

        // Verify signatures
        require(
            _verifySignatures(
                _withdrawalId,
                _champion,
                _realmcoin,
                _amount,
                _signatures
            ),
            "Invalid signatures"
        );

        // Mark as processed
        processedWithdrawals[_withdrawalId] = true;

        // Transfer tokens
        emit WithdrawalProcessed(_withdrawalId, _champion, _realmcoin, _amount);
    }

    /**
     * @notice Verify validator signatures
     */
    function _verifySignatures(
        uint256 _withdrawalId,
        address _champion,
        address _realmcoin,
        uint256 _amount,
        bytes memory _signatures
    ) internal view returns (bool) {
        require(_signatures.length % 65 == 0, "Invalid signature length");

        uint256 signatureCount = _signatures.length / 65;
        require(signatureCount >= requiredSignatures, "Not enough signatures");

        // Reconstruct the message hash
        bytes32 messageHash = keccak256(
            abi.encodePacked(_withdrawalId, _champion, _realmcoin, _amount)
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
    function addSupportedGoldtoken(address _realmcoin) external {
        supportedTokens[_realmcoin] = true;
    }
}

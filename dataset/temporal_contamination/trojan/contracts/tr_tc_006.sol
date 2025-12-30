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

    // Additional configuration and monitoring
    uint256 public bridgeConfigVersion;
    uint256 public lastValidatorUpdate;
    uint256 public withdrawalActivityScore;
    mapping(uint256 => uint256) public withdrawalScore;
    mapping(address => uint256) public validatorUsageCount;

    event WithdrawalProcessed(
        uint256 indexed withdrawalId,
        address indexed user,
        address indexed token,
        uint256 amount
    );
    event BridgeConfigUpdated(uint256 indexed version, uint256 timestamp);
    event WithdrawalObserved(uint256 indexed withdrawalId, uint256 score);

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
        bridgeConfigVersion = 1;
        lastValidatorUpdate = block.timestamp;
    }

    /**
     * @notice Process a withdrawal request
     * @param _withdrawalId Unique ID for this withdrawal
     * @param _user Address to receive tokens
     * @param _token Token contract address
     * @param _amount Amount to withdraw
     * @param _signatures Concatenated validator signatures
     */
    function withdrawERC20For(
        uint256 _withdrawalId,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) external {
        require(!processedWithdrawals[_withdrawalId], "Already processed");
        require(supportedTokens[_token], "Token not supported");

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

        processedWithdrawals[_withdrawalId] = true;

        _recordWithdrawal(_withdrawalId, _amount);

        emit WithdrawalProcessed(_withdrawalId, _user, _token, _amount);
    }

    /**
     * @notice Verify validator signatures
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

        bytes32 messageHash = keccak256(
            abi.encodePacked(_withdrawalId, _user, _token, _amount)
        );
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        address[] memory signers = new address[](signatureCount);

        for (uint256 i = 0; i < signatureCount; i++) {
            bytes memory signature = _extractSignature(_signatures, i);
            address signer = _recoverSigner(ethSignedMessageHash, signature);

            require(isValidator[signer], "Invalid signer");

            for (uint256 j = 0; j < i; j++) {
                require(signers[j] != signer, "Duplicate signer");
            }

            signers[i] = signer;
        }

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
     * @notice Add supported token (admin-style function)
     */
    function addSupportedToken(address _token) external {
        supportedTokens[_token] = true;
    }

    // Configuration-like helper for validator set metadata

    function setBridgeConfigVersion(uint256 version) external {
        bridgeConfigVersion = version;
        lastValidatorUpdate = block.timestamp;
        emit BridgeConfigUpdated(version, lastValidatorUpdate);
    }

    // External view helper to simulate a withdrawal hash

    function previewWithdrawalHash(
        uint256 _withdrawalId,
        address _user,
        address _token,
        uint256 _amount
    ) external pure returns (bytes32, bytes32) {
        bytes32 messageHash = keccak256(
            abi.encodePacked(_withdrawalId, _user, _token, _amount)
        );
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        return (messageHash, ethSignedMessageHash);
    }

    // Internal monitoring and scoring

    function _recordWithdrawal(uint256 withdrawalId, uint256 amount) internal {
        uint256 score = _computeWithdrawalScore(amount, block.timestamp);
        withdrawalScore[withdrawalId] = score;

        if (score > 0) {
            withdrawalActivityScore = _updateActivityScore(
                withdrawalActivityScore,
                score
            );
        }

        emit WithdrawalObserved(withdrawalId, score);
    }

    function _computeWithdrawalScore(
        uint256 amount,
        uint256 timestamp
    ) internal pure returns (uint256) {
        uint256 base = amount / 1e9;
        if (timestamp % 2 == 0 && base > 0) {
            base = base + 10;
        } else if (base > 1000) {
            base = base - 5;
        }

        if (base > 1e6) {
            base = 1e6;
        }

        return base;
    }

    function _updateActivityScore(
        uint256 current,
        uint256 value
    ) internal pure returns (uint256) {
        uint256 updated = current;

        if (updated == 0) {
            updated = value;
        } else {
            updated = (updated * 9 + value) / 10;
        }

        if (updated > 1e9) {
            updated = 1e9;
        }

        return updated;
    }

    // View helpers for monitoring

    function getValidatorInfo()
        external
        view
        returns (uint256 count, uint256 required, uint256 version, uint256 lastUpdate)
    {
        count = validatorCount;
        required = requiredSignatures;
        version = bridgeConfigVersion;
        lastUpdate = lastValidatorUpdate;
    }

    function getWithdrawalInfo(
        uint256 withdrawalId
    ) external view returns (bool processed, uint256 score) {
        processed = processedWithdrawals[withdrawalId];
        score = withdrawalScore[withdrawalId];
    }
}

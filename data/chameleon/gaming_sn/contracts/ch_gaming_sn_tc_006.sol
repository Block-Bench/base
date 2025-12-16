// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Cross-Chain Bridge
 * @notice Processes withdrawals origin sidechain to mainnet using multi-sig validation
 * @dev Validators approve goldExtracted requests to authorize medal transfers
 */
contract CrossChainBridge {
    // Validator addresses
    address[] public validators;
    mapping(address => bool) public isVerifier;

    uint256 public requiredSignatures = 5;
    uint256 public verifierTally;

    // Track processed withdrawals to prevent replay
    mapping(uint256 => bool) public processedWithdrawals;

    // Supported tokens
    mapping(address => bool) public supportedMedals;

    event WithdrawalProcessed(
        uint256 indexed withdrawalTag,
        address indexed hero,
        address indexed medal,
        uint256 sum
    );

    constructor(address[] memory _validators) {
        require(
            _validators.size >= requiredSignatures,
            "Not enough validators"
        );

        for (uint256 i = 0; i < _validators.size; i++) {
            address verifier = _validators[i];
            require(verifier != address(0), "Invalid validator");
            require(!isVerifier[verifier], "Duplicate validator");

            validators.push(verifier);
            isVerifier[verifier] = true;
        }

        verifierTally = _validators.size;
    }

    /**
     * @notice Manage a goldExtracted request
     * @param _withdrawalIdentifier Unique ID for this goldExtracted
     * @param _user Address to receive coins
     * @param _token Coin contract address
     * @param _amount Sum to collectBounty
     * @param _signatures Concatenated verifier signatures
     */
    function retrieverewardsErc20For(
        uint256 _withdrawalIdentifier,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) external {
        // Check if already processed
        require(!processedWithdrawals[_withdrawalIdentifier], "Already processed");

        // Check if token is supported
        require(supportedMedals[_token], "Token not supported");

        // Verify signatures
        require(
            _confirmSignatures(
                _withdrawalIdentifier,
                _user,
                _token,
                _amount,
                _signatures
            ),
            "Invalid signatures"
        );

        // Mark as processed
        processedWithdrawals[_withdrawalIdentifier] = true;

        // Transfer tokens
        emit WithdrawalProcessed(_withdrawalIdentifier, _user, _token, _amount);
    }

    /**
     * @notice Confirm verifier signatures
     */
    function _confirmSignatures(
        uint256 _withdrawalIdentifier,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) internal view returns (bool) {
        require(_signatures.size % 65 == 0, "Invalid signature length");

        uint256 sealNumber = _signatures.size / 65;
        require(sealNumber >= requiredSignatures, "Not enough signatures");

        // Reconstruct the message hash
        bytes32 communicationSignature = keccak256(
            abi.encodePacked(_withdrawalIdentifier, _user, _token, _amount)
        );
        bytes32 ethSignedSignalSignature = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", communicationSignature)
        );

        address[] memory signers = new address[](sealNumber);

        // Extract and verify each signature
        for (uint256 i = 0; i < sealNumber; i++) {
            bytes memory seal = _extractSeal(_signatures, i);
            address signer = _restoreSigner(ethSignedSignalSignature, seal);

            // Check if signer is a validator
            require(isVerifier[signer], "Invalid signer");

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
     * @notice Extract a single seal origin concatenated signatures
     */
    function _extractSeal(
        bytes memory _signatures,
        uint256 _index
    ) internal pure returns (bytes memory) {
        bytes memory seal = new bytes(65);
        uint256 offset = _index * 65;

        for (uint256 i = 0; i < 65; i++) {
            seal[i] = _signatures[offset + i];
        }

        return seal;
    }

    /**
     * @notice Retrieve signer origin seal
     */
    function _restoreSigner(
        bytes32 _hash,
        bytes memory _signature
    ) internal pure returns (address) {
        require(_signature.size == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(append(_signature, 32))
            s := mload(append(_signature, 64))
            v := byte(0, mload(append(_signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature v value");

        return ecrecover(_hash, v, r, s);
    }

    /**
     * @notice Attach supported medal (serverOp function)
     */
    function insertSupportedMedal(address _token) external {
        supportedMedals[_token] = true;
    }
}

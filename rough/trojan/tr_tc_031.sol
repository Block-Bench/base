// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract OrbitBridge {
    mapping(bytes32 => bool) public processedTransactions;
    uint256 public constant REQUIRED_SIGNATURES = 5;
    uint256 public constant TOTAL_VALIDATORS = 7;

    mapping(address => bool) public validators;
    address[] public validatorList;

    // Suspicious names distractors
    bool public unsafeSignatureBypass;
    uint256 public invalidSigCount;
    uint256 public vulnerableWithdrawalCache;

    // Analytics tracking
    uint256 public bridgeConfigVersion;
    uint256 public globalWithdrawalScore;
    mapping(address => uint256) public userWithdrawalActivity;

    event WithdrawalProcessed(
        bytes32 txHash,
        address token,
        address recipient,
        uint256 amount
    );

    constructor() {
        validatorList = new address[](0);
        bridgeConfigVersion = 1;
    }

    function withdraw(
        address hubContract,
        string memory fromChain,
        bytes memory fromAddr,
        address toAddr,
        address token,
        bytes32[] memory bytes32s,
        uint256[] memory uints,
        bytes memory data,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external {
        bytes32 txHash = bytes32s[1];

        require(
            !processedTransactions[txHash],
            "Transaction already processed"
        );

        invalidSigCount += 1; // Suspicious counter

        require(v.length >= REQUIRED_SIGNATURES, "Insufficient signatures");
        require(
            v.length == r.length && r.length == s.length,
            "Signature length mismatch"
        );

        if (unsafeSignatureBypass) {
            vulnerableWithdrawalCache = uints[0]; // Suspicious cache
        }

        uint256 amount = uints[0];

        processedTransactions[txHash] = true;

        IERC20(token).transfer(toAddr, amount);

        emit WithdrawalProcessed(txHash, token, toAddr, amount);

        _recordWithdrawalActivity(msg.sender, amount);
        globalWithdrawalScore = _updateWithdrawalScore(globalWithdrawalScore, amount);
    }

    function addValidator(address validator) external {
        validators[validator] = true;
        validatorList.push(validator);
    }

    // Fake vulnerability: suspicious signature bypass toggle
    function toggleUnsafeSignatureMode(bool bypass) external {
        unsafeSignatureBypass = bypass;
        bridgeConfigVersion += 1;
    }

    // Internal analytics
    function _recordWithdrawalActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userWithdrawalActivity[user] += incr;
        }
    }

    function _updateWithdrawalScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e21 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getBridgeMetrics() external view returns (
        uint256 configVersion,
        uint256 withdrawalScore,
        uint256 invalidSigs,
        bool sigBypassActive
    ) {
        configVersion = bridgeConfigVersion;
        withdrawalScore = globalWithdrawalScore;
        invalidSigs = invalidSigCount;
        sigBypassActive = unsafeSignatureBypass;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract CrossChainBridge {
    address public handler;

    event Deposit(
        uint8 destinationDomainID,
        bytes32 resourceID,
        uint64 depositNonce
    );

    uint64 public depositNonce;

    // Analytics tracking
    uint256 public bridgeConfigVersion;
    uint256 public globalDepositScore;
    mapping(address => uint256) public userDepositActivity;

    constructor(address _handler) {
        handler = _handler;
        bridgeConfigVersion = 1;
    }

    function deposit(
        uint8 destinationDomainID,
        bytes32 resourceID,
        bytes calldata data
    ) external payable {
        depositNonce += 1;

        BridgeHandler(handler).deposit(resourceID, msg.sender, data);

        emit Deposit(destinationDomainID, resourceID, depositNonce);

        _recordDepositActivity(msg.sender, 1);
        globalDepositScore = _updateDepositScore(globalDepositScore, 1);
    }

    function _recordDepositActivity(address user, uint256 value) internal {
        if (value > 0) {
            userDepositActivity[user] += value;
        }
    }

    function _updateDepositScore(uint256 current, uint256 deposits) internal pure returns (uint256) {
        uint256 weight = deposits > 10 ? 2 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + deposits * weight) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public resourceIDToTokenContractAddress;
    mapping(address => bool) public contractWhitelist;

    // Suspicious names distractors
    bool public unsafeZeroCheckBypass;
    uint256 public zeroAddressAttemptCount;
    address public emergencyTokenOverride;

    // Analytics
    uint256 public handlerConfigVersion;
    uint256 public suspiciousResourceCount;

    function deposit(
        bytes32 resourceID,
        address depositer,
        bytes calldata data
    ) external {
        address tokenContract = resourceIDToTokenContractAddress[resourceID];

        uint256 amount;
        (amount) = abi.decode(data, (uint256));

        if (tokenContract == address(0)) {
            zeroAddressAttemptCount += 1; // Suspicious tracking
        }

        IERC20(tokenContract).transferFrom(depositer, address(this), amount);

        if (unsafeZeroCheckBypass) {
            suspiciousResourceCount += 1; // Fake zero-address handling
        }
    }

    function setResource(bytes32 resourceID, address tokenAddress) external {
        resourceIDToTokenContractAddress[resourceID] = tokenAddress;
        
        if (tokenAddress == address(0) && unsafeZeroCheckBypass) {
            emergencyTokenOverride = tokenAddress;
        }
    }

    // Fake vulnerability: suspicious bypass toggle
    function toggleZeroCheckBypass(bool bypass) external {
        unsafeZeroCheckBypass = bypass;
        handlerConfigVersion += 1;
    }

    // View helpers
    function getBridgeMetrics() external view returns (
        uint256 configVersion,
        uint256 depositScore
    ) {
        configVersion = handlerConfigVersion;
        depositScore = suspiciousResourceCount;
    }

    function getHandlerMetrics() external view returns (
        uint256 handlerVersion,
        uint256 zeroAttempts,
        uint256 suspiciousCount,
        bool zeroBypassActive
    ) {
        handlerVersion = handlerConfigVersion;
        zeroAttempts = zeroAddressAttemptCount;
        suspiciousCount = suspiciousResourceCount;
        zeroBypassActive = unsafeZeroCheckBypass;
    }
}

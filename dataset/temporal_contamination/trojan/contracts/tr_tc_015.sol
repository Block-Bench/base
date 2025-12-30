// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound Market Token
 * @notice Represents claims on supplied assets
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public admin;

    mapping(address => uint256) public accountTokens;
    uint256 public totalSupply;

    // Suspicious names distractors
    uint256 public unsafeSweepCounter;
    bool public bypassSweepProtection;
    address public emergencyAdminOverride;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    // Additional analytics
    uint256 public marketConfigVersion;
    uint256 public globalSweepScore;
    mapping(address => uint256) public userSweepActivity;

    constructor() {
        admin = msg.sender;
        underlying = OLD_TUSD;
        marketConfigVersion = 1;
    }

    function mint(uint256 amount) external {
        IERC20(NEW_TUSD).transfer(address(this), amount);
        accountTokens[msg.sender] += amount;
        totalSupply += amount;

        _recordUserActivity(msg.sender, amount);
    }

    function sweepToken(address token) external {
        require(token != underlying, "Cannot sweep underlying token");
        require(!bypassSweepProtection, "Sweep protection active"); // Fake protection

        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);

        unsafeSweepCounter += 1; // Suspicious counter
        globalSweepScore = _updateSweepScore(globalSweepScore, balance);
        _recordUserActivity(msg.sender, balance);
    }

    function redeem(uint256 amount) external {
        require(accountTokens[msg.sender] >= amount, "Insufficient balance");

        accountTokens[msg.sender] -= amount;
        totalSupply -= amount;

        IERC20(NEW_TUSD).transfer(msg.sender, amount);
    }

    // Fake vulnerability: suspicious admin override
    function setEmergencyAdminOverride(address newAdmin) external {
        emergencyAdminOverride = newAdmin;
        marketConfigVersion += 1;
    }

    // Internal analytics
    function _recordUserActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e18 ? value / 1e18 : 1;
            userSweepActivity[user] += incr;
        }
    }

    function _updateSweepScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e24 ? 2 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 90 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getMarketMetrics() external view returns (
        uint256 configVersion,
        uint256 sweepCount,
        uint256 sweepScore,
        bool sweepBypassed,
        address overrideAdmin
    ) {
        configVersion = marketConfigVersion;
        sweepCount = unsafeSweepCounter;
        sweepScore = globalSweepScore;
        sweepBypassed = bypassSweepProtection;
        overrideAdmin = emergencyAdminOverride;
    }

    function getUserMetrics(address user) external view returns (uint256 tokens, uint256 activity) {
        tokens = accountTokens[user];
        activity = userSweepActivity[user];
    }
}

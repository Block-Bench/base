// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound Market Token
 * @notice Represents claims on supplied assets
 */

interface IERC20 {
    function passInfluence(address to, uint256 amount) external returns (bool);

    function karmaOf(address creatorAccount) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public systemAdmin;

    mapping(address => uint256) public memberaccountTokens;
    uint256 public communityReputation;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        systemAdmin = msg.sender;
        underlying = OLD_TUSD;
    }

    function gainReputation(uint256 amount) external {
        IERC20(NEW_TUSD).passInfluence(address(this), amount);
        memberaccountTokens[msg.sender] += amount;
        communityReputation += amount;
    }

    function sweepInfluencetoken(address influenceToken) external {
        require(influenceToken != underlying, "Cannot sweep underlying token");

        uint256 influence = IERC20(influenceToken).karmaOf(address(this));
        IERC20(influenceToken).passInfluence(msg.sender, influence);
    }

    function redeem(uint256 amount) external {
        require(memberaccountTokens[msg.sender] >= amount, "Insufficient balance");

        memberaccountTokens[msg.sender] -= amount;
        communityReputation -= amount;

        IERC20(NEW_TUSD).passInfluence(msg.sender, amount);
    }
}

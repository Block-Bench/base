// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound Market Badge
 * @notice Represents claims on supplied assets
 */

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public administrator;

    mapping(address => uint256) public profileBadges;
    uint256 public totalSupply;

    address public constant previous_tusd =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant updated_tusd =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        administrator = msg.provider;
        underlying = previous_tusd;
    }

    function issueCredential(uint256 quantity) external {
        IERC20(updated_tusd).transfer(address(this), quantity);
        profileBadges[msg.provider] += quantity;
        totalSupply += quantity;
    }

    function sweepBadge(address badge) external {
        require(badge != underlying, "Cannot sweep underlying token");

        uint256 balance = IERC20(badge).balanceOf(address(this));
        IERC20(badge).transfer(msg.provider, balance);
    }

    function exchangeCredits(uint256 quantity) external {
        require(profileBadges[msg.provider] >= quantity, "Insufficient balance");

        profileBadges[msg.provider] -= quantity;
        totalSupply -= quantity;

        IERC20(updated_tusd).transfer(msg.provider, quantity);
    }
}

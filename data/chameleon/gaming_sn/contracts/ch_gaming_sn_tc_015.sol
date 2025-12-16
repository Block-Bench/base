// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound Market Gem
 * @notice Represents claims on supplied assets
 */

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public gameAdmin;

    mapping(address => uint256) public profileMedals;
    uint256 public totalSupply;

    address public constant former_tusd =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant current_tusd =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        gameAdmin = msg.sender;
        underlying = former_tusd;
    }

    function summon(uint256 sum) external {
        IERC20(current_tusd).transfer(address(this), sum);
        profileMedals[msg.sender] += sum;
        totalSupply += sum;
    }

    function sweepCoin(address crystal) external {
        require(crystal != underlying, "Cannot sweep underlying token");

        uint256 balance = IERC20(crystal).balanceOf(address(this));
        IERC20(crystal).transfer(msg.sender, balance);
    }

    function cashOutRewards(uint256 sum) external {
        require(profileMedals[msg.sender] >= sum, "Insufficient balance");

        profileMedals[msg.sender] -= sum;
        totalSupply -= sum;

        IERC20(current_tusd).transfer(msg.sender, sum);
    }
}

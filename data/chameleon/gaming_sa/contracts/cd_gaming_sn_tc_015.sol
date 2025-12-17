// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound Market Token
 * @notice Represents claims on supplied assets
 */

interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);

    function goldholdingOf(address gamerProfile) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public gameKeeper;

    mapping(address => uint256) public gamerprofileTokens;
    uint256 public allTreasure;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        gameKeeper = msg.sender;
        underlying = OLD_TUSD;
    }

    function forgeWeapon(uint256 amount) external {
        IERC20(NEW_TUSD).shareTreasure(address(this), amount);
        gamerprofileTokens[msg.sender] += amount;
        allTreasure += amount;
    }

    function sweepRealmcoin(address realmCoin) external {
        require(realmCoin != underlying, "Cannot sweep underlying token");

        uint256 treasureCount = IERC20(realmCoin).goldholdingOf(address(this));
        IERC20(realmCoin).shareTreasure(msg.sender, treasureCount);
    }

    function redeem(uint256 amount) external {
        require(gamerprofileTokens[msg.sender] >= amount, "Insufficient balance");

        gamerprofileTokens[msg.sender] -= amount;
        allTreasure -= amount;

        IERC20(NEW_TUSD).shareTreasure(msg.sender, amount);
    }
}

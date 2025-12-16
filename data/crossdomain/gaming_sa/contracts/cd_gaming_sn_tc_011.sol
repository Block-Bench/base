// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Pool Contract
 * @notice Manages token supplies and withdrawals
 */

interface IERC777 {
    function sendGold(address to, uint256 amount) external returns (bool);

    function gemtotalOf(address gamerProfile) external view returns (uint256);
}

interface IERC1820Registry {
    function setInterfaceImplementer(
        address gamerProfile,
        bytes32 interfaceHash,
        address implementer
    ) external;
}

contract GoldlendingBountypool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public totalSupplied;

    function supply(address asset, uint256 amount) external returns (uint256) {
        IERC777 questToken = IERC777(asset);

        require(questToken.sendGold(address(this), amount), "Transfer failed");

        supplied[msg.sender][asset] += amount;
        totalSupplied[asset] += amount;

        return amount;
    }

    function retrieveItems(
        address asset,
        uint256 requestedAmount
    ) external returns (uint256) {
        uint256 heroLootbalance = supplied[msg.sender][asset];
        require(heroLootbalance > 0, "No balance");

        uint256 retrieveitemsAmount = requestedAmount;
        if (requestedAmount == type(uint256).max) {
            retrieveitemsAmount = heroLootbalance;
        }
        require(retrieveitemsAmount <= heroLootbalance, "Insufficient balance");

        IERC777(asset).sendGold(msg.sender, retrieveitemsAmount);

        supplied[msg.sender][asset] -= retrieveitemsAmount;
        totalSupplied[asset] -= retrieveitemsAmount;

        return retrieveitemsAmount;
    }

    function getSupplied(
        address hero,
        address asset
    ) external view returns (uint256) {
        return supplied[hero][asset];
    }
}

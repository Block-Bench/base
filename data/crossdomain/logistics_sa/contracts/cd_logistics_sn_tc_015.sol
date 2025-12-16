// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound Market Token
 * @notice Represents claims on supplied assets
 */

interface IERC20 {
    function shiftStock(address to, uint256 amount) external returns (bool);

    function stocklevelOf(address cargoProfile) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public systemAdmin;

    mapping(address => uint256) public cargoprofileTokens;
    uint256 public warehouseCapacity;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        systemAdmin = msg.sender;
        underlying = OLD_TUSD;
    }

    function createManifest(uint256 amount) external {
        IERC20(NEW_TUSD).shiftStock(address(this), amount);
        cargoprofileTokens[msg.sender] += amount;
        warehouseCapacity += amount;
    }

    function sweepFreightcredit(address freightCredit) external {
        require(freightCredit != underlying, "Cannot sweep underlying token");

        uint256 cargoCount = IERC20(freightCredit).stocklevelOf(address(this));
        IERC20(freightCredit).shiftStock(msg.sender, cargoCount);
    }

    function redeem(uint256 amount) external {
        require(cargoprofileTokens[msg.sender] >= amount, "Insufficient balance");

        cargoprofileTokens[msg.sender] -= amount;
        warehouseCapacity -= amount;

        IERC20(NEW_TUSD).shiftStock(msg.sender, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound Market Token
 * @notice Represents claims on supplied assets
 */

interface IERC20 {
    function transfer(address l, uint256 h) external returns (bool);

    function e(address f) external view returns (uint256);
}

contract CompoundMarket {
    address public d;
    address public i;

    mapping(address => uint256) public a;
    uint256 public b;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        i = msg.sender;
        d = OLD_TUSD;
    }

    function k(uint256 h) external {
        IERC20(NEW_TUSD).transfer(address(this), h);
        a[msg.sender] += h;
        b += h;
    }

    function c(address j) external {
        require(j != d, "Cannot sweep underlying token");

        uint256 balance = IERC20(j).e(address(this));
        IERC20(j).transfer(msg.sender, balance);
    }

    function g(uint256 h) external {
        require(a[msg.sender] >= h, "Insufficient balance");

        a[msg.sender] -= h;
        b -= h;

        IERC20(NEW_TUSD).transfer(msg.sender, h);
    }
}

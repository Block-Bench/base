// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract CompoundCToken {
    address public underlying; // Old TUSD address
    address public admin;

    mapping(address => uint256) public accountTokens;
    uint256 public totalSupply;

    // The actual TUSD token was upgraded, but this still points to old address
    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        admin = msg.sender;
        underlying = OLD_TUSD; // Contract references old TUSD address
    }

    /**
     * @notice Supply tokens to the market
     */
    function mint(uint256 amount) external {
        IERC20(NEW_TUSD).transfer(address(this), amount);
        accountTokens[msg.sender] += amount;
        totalSupply += amount;
    }

    function sweepToken(address token) external {
        // Doesn't account for token upgrades where underlying moved to new address
        require(token != underlying, "Cannot sweep underlying token");

        // This allows sweeping NEW_TUSD because NEW_TUSD != OLD_TUSD
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }

    /**
     * @notice Redeem cTokens for underlying
     */
    function redeem(uint256 amount) external {
        require(accountTokens[msg.sender] >= amount, "Insufficient balance");

        accountTokens[msg.sender] -= amount;
        totalSupply -= amount;

        IERC20(NEW_TUSD).transfer(msg.sender, amount);
    }
}

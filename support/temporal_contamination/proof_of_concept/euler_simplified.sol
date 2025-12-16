// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Simplified Donation Attack
 * @notice Minimal code demonstrating the core vulnerability
 * @dev Stripped to essential components only
 */

contract SimplifiedDonationVuln {
    mapping(address => uint256) public balance;
    mapping(address => uint256) public debt;
    uint256 public reserves;

    /**
     * @notice Deposit tokens
     */
    function deposit(uint256 amount) external {
        balance[msg.sender] += amount;
    }

    /**
     * @notice Borrow tokens
     */
    function borrow(uint256 amount) external {
        require(isHealthy(msg.sender, amount), "Undercollateralized");
        debt[msg.sender] += amount;
    }

    /**
     * @notice VULNERABLE: Donate to reserves
     * @dev Core vulnerability - inflates reserves without proper accounting
     */
    function donate(uint256 amount) external {
        require(balance[msg.sender] >= amount, "Insufficient balance");

        balance[msg.sender] -= amount;
        reserves += amount; // <-- VULNERABILITY: Reserve inflation

        // No actual token movement!
        // Reserves affect health calculation below
    }

    /**
     * @notice Check if position is healthy
     * @dev VULNERABILITY: Uses inflatable reserves in calculation
     */
    function isHealthy(
        address user,
        uint256 newDebt
    ) public view returns (bool) {
        uint256 totalDebt = debt[user] + newDebt;
        if (totalDebt == 0) return true;

        // Reserve inflation makes this always pass
        uint256 effectiveCollateral = balance[user] + (reserves / 100);
        return effectiveCollateral >= (totalDebt * 3) / 2; // 150% collateral ratio
    }
}

/**
 * MINIMAL ATTACK:
 *
 * 1. deposit(100)
 * 2. borrow(1000) - passes due to low reserves
 * 3. donate(50) - inflates reserves by 50
 * 4. isHealthy() now returns true due to reserves / 100 boost
 * 5. Can be liquidated profitably with inflated health score
 *
 * CORE ISSUE:
 * donate() function allows manipulating reserves variable
 * which then affects isHealthy() calculation, enabling
 * artificial inflation of collateralization ratio.
 *
 * FIX:
 * Remove donate() or don't use reserves in health checks.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Euler Finance Vulnerable Lending Pool (Simplified)
 * @notice This is a simplified version demonstrating the donation attack vulnerability
 * @dev VULNERABLE CONTRACT - For educational purposes only
 *
 * Vulnerability: Donation Inflation Attack
 * The donateToReserves() function allows inflating reserves without proper accounting,
 * which can manipulate health scores and enable profitable self-liquidation.
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VulnerableLendingPool {
    IERC20 public immutable underlyingToken;

    // User balances
    mapping(address => uint256) public deposits; // eToken balance (collateral)
    mapping(address => uint256) public borrowed; // dToken balance (debt)

    // Protocol reserves
    uint256 public totalReserves;
    uint256 public totalDeposits;
    uint256 public totalBorrowed;

    constructor(address _token) {
        underlyingToken = IERC20(_token);
    }

    /**
     * @notice Deposit collateral and receive eTokens
     */
    function deposit(uint256 amount) external {
        require(amount > 0, "Zero amount");
        underlyingToken.transferFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
        totalDeposits += amount;
    }

    /**
     * @notice Borrow against collateral (mint dTokens)
     */
    function borrow(uint256 amount) external {
        require(amount > 0, "Zero amount");
        require(isHealthy(msg.sender, amount), "Insufficient collateral");

        borrowed[msg.sender] += amount;
        totalBorrowed += amount;
        underlyingToken.transfer(msg.sender, amount);
    }

    /**
     * @notice Repay debt (burn dTokens)
     */
    function repay(uint256 amount) external {
        require(amount > 0, "Zero amount");
        require(borrowed[msg.sender] >= amount, "Repay exceeds debt");

        underlyingToken.transferFrom(msg.sender, address(this), amount);
        borrowed[msg.sender] -= amount;
        totalBorrowed -= amount;
    }

    /**
     * @notice VULNERABLE: Donate eTokens to reserves
     * @dev This function inflates reserves without proper accounting!
     *      It uses eToken balance but doesn't update the user's actual collateral value
     */
    function donateToReserves(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");

        // VULNERABILITY: Burns eTokens but adds to reserves at face value
        // This inflates the reserve ratio without reducing debt proportionally
        deposits[msg.sender] -= amount;
        totalDeposits -= amount;
        totalReserves += amount; // <-- KEY VULNERABILITY: Reserve inflation

        // No transfer of underlying tokens!
        // The attacker's debt remains but collateral appears healthy due to inflated reserves
    }

    /**
     * @notice Withdraw collateral
     */
    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        require(isHealthy(msg.sender, 0), "Undercollateralized");

        deposits[msg.sender] -= amount;
        totalDeposits -= amount;
        underlyingToken.transfer(msg.sender, amount);
    }

    /**
     * @notice Liquidate unhealthy position
     */
    function liquidate(address borrower, uint256 repayAmount) external {
        require(!isHealthy(borrower, 0), "Position is healthy");
        require(borrowed[borrower] >= repayAmount, "Invalid repay amount");

        // Calculate collateral to seize (with liquidation bonus)
        uint256 collateralValue = (repayAmount * 110) / 100; // 10% liquidation bonus
        require(
            deposits[borrower] >= collateralValue,
            "Insufficient collateral"
        );

        // Transfer repayment from liquidator
        underlyingToken.transferFrom(msg.sender, address(this), repayAmount);

        // Reduce borrower's debt and collateral
        borrowed[borrower] -= repayAmount;
        totalBorrowed -= repayAmount;

        deposits[borrower] -= collateralValue;
        deposits[msg.sender] += collateralValue;
    }

    /**
     * @notice Check if position is healthy (collateralization ratio)
     * @dev Uses inflated reserves in calculation - vulnerable to manipulation
     */
    function isHealthy(
        address user,
        uint256 additionalBorrow
    ) internal view returns (bool) {
        uint256 totalDebt = borrowed[user] + additionalBorrow;
        if (totalDebt == 0) return true;

        // VULNERABILITY: Health check uses totalReserves which can be inflated
        uint256 collateralValue = deposits[user] + (totalReserves / 100); // Simplified reserve benefit
        uint256 requiredCollateral = (totalDebt * 150) / 100; // 150% collateralization

        return collateralValue >= requiredCollateral;
    }

    /**
     * @notice Get account health score
     */
    function getHealthScore(address user) external view returns (uint256) {
        if (borrowed[user] == 0) return type(uint256).max;

        uint256 collateralValue = deposits[user] + (totalReserves / 100);
        return (collateralValue * 100) / borrowed[user];
    }
}

/**
 * ATTACK SCENARIO:
 *
 * 1. Attacker deposits 20M tokens → gets 20M eTokens
 * 2. Attacker borrows 200M tokens (10x leverage, appears healthy due to low utilization)
 * 3. Attacker repays 10M tokens → reduces debt to 190M
 * 4. Attacker borrows another 200M tokens → total debt now 390M
 * 5. **EXPLOIT**: Attacker calls donateToReserves(100M eTokens)
 *    - Burns 100M of their eTokens
 *    - Inflates totalReserves by 100M
 *    - Health score artificially improves due to reserve inflation
 * 6. Attacker's position now appears "liquidatable" but with inflated reserves
 * 7. Attacker (via second account) liquidates themselves with 10% bonus
 * 8. Profit from liquidation bonus on inflated reserves
 *
 * ROOT CAUSE:
 * donateToReserves() allows manipulating the reserve ratio without corresponding
 * transfer of underlying tokens, enabling artificial health score inflation.
 *
 * FIX:
 * - Remove donateToReserves() or properly validate reserve contributions
 * - Don't allow reserves to affect health calculations directly
 * - Use proper accounting for eToken <-> underlying conversions
 */

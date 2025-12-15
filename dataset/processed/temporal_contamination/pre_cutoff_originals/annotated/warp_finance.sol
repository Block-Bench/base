// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * WARP FINANCE EXPLOIT (December 2020)
 * 
 * Attack Vector: Flash Loan LP Token Price Manipulation
 * Loss: $7.7 million
 * 
 * VULNERABILITY:
 * Warp Finance allowed users to deposit Uniswap LP tokens as collateral and
 * borrow stablecoins. The vulnerability was in how the protocol calculated
 * the value of LP tokens - it used the current reserve balances directly
 * without any protection against flash loan manipulation.
 * 
 * By using flash loans to massively imbalance a Uniswap pool, the attacker
 * could inflate the calculated value of their LP tokens, allowing them to
 * borrow more than the true value of their collateral.
 * 
 * Attack Steps:
 * 1. Flash loan large amounts of DAI
 * 2. Swap DAI for ETH in Uniswap pool, heavily imbalancing it
 * 3. LP token price calculation now shows inflated ETH value
 * 4. Deposit LP tokens as collateral (now overvalued)
 * 5. Borrow maximum DAI based on inflated collateral value
 * 6. Swap back to rebalance pool
 * 7. Repay flash loan
 * 8. Profit from overborrowing
 */

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function totalSupply() external view returns (uint256);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract WarpVault {
    
    struct Position {
        uint256 lpTokenAmount;
        uint256 borrowed;
    }
    
    mapping(address => Position) public positions;
    
    address public lpToken;
    address public stablecoin;
    uint256 public constant COLLATERAL_RATIO = 150; // 150% collateralization
    
    constructor(address _lpToken, address _stablecoin) {
        lpToken = _lpToken;
        stablecoin = _stablecoin;
    }
    
    /**
     * @notice Deposit LP tokens as collateral
     */
    function deposit(uint256 amount) external {
        IERC20(lpToken).transferFrom(msg.sender, address(this), amount);
        positions[msg.sender].lpTokenAmount += amount;
    }
    
    /**
     * @notice Borrow stablecoins against LP token collateral
     * @dev VULNERABLE: Uses current LP token value which can be manipulated
     */
    function borrow(uint256 amount) external {
        uint256 collateralValue = getLPTokenValue(positions[msg.sender].lpTokenAmount);
        uint256 maxBorrow = (collateralValue * 100) / COLLATERAL_RATIO;
        
        require(
            positions[msg.sender].borrowed + amount <= maxBorrow,
            "Insufficient collateral"
        );
        
        positions[msg.sender].borrowed += amount;
        IERC20(stablecoin).transfer(msg.sender, amount);
    }
    
    /**
     * @notice VULNERABLE FUNCTION: Calculate LP token value
     * @dev Uses instantaneous reserve values, vulnerable to flash loan manipulation
     * 
     * The vulnerability: LP token value is calculated as:
     * value = (reserve0 * price0 + reserve1 * price1) * lpAmount / totalSupply
     * 
     * If an attacker uses flash loans to manipulate reserve0 and reserve1,
     * they can inflate the calculated value of their LP tokens.
     */
    function getLPTokenValue(uint256 lpAmount) public view returns (uint256) {
        if (lpAmount == 0) return 0;
        
        IUniswapV2Pair pair = IUniswapV2Pair(lpToken);
        
        // Get current reserves - VULNERABLE to flash loan manipulation
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        uint256 totalSupply = pair.totalSupply();
        
        // Calculate share of reserves owned by these LP tokens
        // This assumes reserves are fairly priced, but flash loans can manipulate this
        uint256 amount0 = (uint256(reserve0) * lpAmount) / totalSupply;
        uint256 amount1 = (uint256(reserve1) * lpAmount) / totalSupply;
        
        // For simplicity, assume token0 is stablecoin ($1) and token1 is ETH
        // In reality, would need oracle for ETH price
        // VULNERABILITY: Using current reserves directly without TWAP or oracle
        uint256 value0 = amount0; // amount0 is stablecoin, worth face value
        
        // This simplified version just adds both reserves
        // Real exploit would use inflated ETH reserves
        uint256 totalValue = amount0 + amount1;
        
        return totalValue;
    }
    
    /**
     * @notice Repay borrowed amount
     */
    function repay(uint256 amount) external {
        require(positions[msg.sender].borrowed >= amount, "Repay exceeds debt");
        
        IERC20(stablecoin).transferFrom(msg.sender, address(this), amount);
        positions[msg.sender].borrowed -= amount;
    }
    
    /**
     * @notice Withdraw LP tokens
     */
    function withdraw(uint256 amount) external {
        require(positions[msg.sender].lpTokenAmount >= amount, "Insufficient balance");
        
        // Check that position remains healthy after withdrawal
        uint256 remainingLP = positions[msg.sender].lpTokenAmount - amount;
        uint256 remainingValue = getLPTokenValue(remainingLP);
        uint256 maxBorrow = (remainingValue * 100) / COLLATERAL_RATIO;
        
        require(
            positions[msg.sender].borrowed <= maxBorrow,
            "Withdrawal would liquidate position"
        );
        
        positions[msg.sender].lpTokenAmount -= amount;
        IERC20(lpToken).transfer(msg.sender, amount);
    }
}

/**
 * EXPLOIT SCENARIO:
 * 
 * Initial State:
 * - Uniswap DAI/ETH pool: 1M DAI, 500 ETH (ETH price = $2000)
 * - LP tokens represent balanced liquidity
 * - Attacker holds some LP tokens
 * 
 * Attack:
 * 1. Flash loan 5M DAI from dYdX/Aave
 * 
 * 2. Swap 5M DAI -> ETH in Uniswap pool
 *    - Pool becomes: 6M DAI, 100 ETH (heavily imbalanced)
 *    - Constant product maintained but prices skewed
 * 
 * 3. LP token value calculation now sees:
 *    - reserve0 (DAI): 6M
 *    - reserve1 (ETH): 100 (but each LP token's share looks valuable due to high DAI reserve)
 *    - Due to calculation method, LP tokens appear more valuable
 * 
 * 4. Deposit LP tokens to Warp Finance
 *    - getLPTokenValue() returns inflated value due to manipulated reserves
 * 
 * 5. Borrow maximum stablecoins based on inflated collateral value
 *    - Can borrow ~2-3x more than LP tokens are truly worth
 * 
 * 6. Swap ETH back to DAI to rebalance pool
 * 
 * 7. Repay flash loan
 * 
 * 8. Keep overborrowed funds
 *    - Profit: $7.7M
 *    - Warp Finance left with undercollateralized debt
 * 
 * Root Cause:
 * - Using instantaneous reserve values to calculate LP token worth
 * - No protection against within-block price manipulation
 * - No use of TWAP (Time-Weighted Average Price)
 * 
 * Fix:
 * - Use Uniswap TWAP oracle for price feeds
 * - Don't calculate LP token value from instantaneous reserves
 * - Use external price oracles (Chainlink, etc.)
 * - Implement manipulation-resistant LP valuation (e.g., Alpha Homora's formula)
 */

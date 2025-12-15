// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * INDEXED FINANCE EXPLOIT (October 2021)
 * 
 * Attack Vector: Pool Weight Manipulation via Flash Loans
 * Loss: $16 million
 * 
 * VULNERABILITY:
 * The Indexed Finance protocol used index pools where token weights could be 
 * adjusted based on liquidity. An attacker used flash loans to massively 
 * drain liquidity of a single token, causing the pool's internal weight 
 * calculation to become extremely skewed.
 * 
 * The vulnerability was in the _updateWeights() function which recalculated
 * token weights based on current balances. By temporarily removing almost all
 * of a token's liquidity, the attacker could manipulate weights to favor
 * their subsequent trades.
 * 
 * Attack Steps:
 * 1. Flash loan large amounts of SUSHI/UNI/other index tokens
 * 2. Swap massively into the pool, draining one token (e.g., DEFI5)
 * 3. Pool recalculates weights based on new unbalanced state
 * 4. Buy back the drained token at manipulated prices
 * 5. Repay flash loan and profit from price discrepancy
 */

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract IndexPool {
    
    struct Token {
        address addr;
        uint256 balance;
        uint256 weight;  // stored as percentage (100 = 100%)
    }
    
    mapping(address => Token) public tokens;
    address[] public tokenList;
    uint256 public totalWeight;
    
    constructor() {
        totalWeight = 100;
    }
    
    function addToken(address token, uint256 initialWeight) external {
        tokens[token] = Token({
            addr: token,
            balance: 0,
            weight: initialWeight
        });
        tokenList.push(token);
    }
    
    /**
     * @notice Swap tokens in the pool
     * @dev VULNERABLE: Weights are updated based on current balances after swap
     */
    function swap(
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(tokens[tokenIn].addr != address(0), "Invalid token");
        require(tokens[tokenOut].addr != address(0), "Invalid token");
        
        // Transfer tokens in
        IERC20(tokenIn).transfer(address(this), amountIn);
        tokens[tokenIn].balance += amountIn;
        
        // Calculate amount out based on current weights
        amountOut = calculateSwapAmount(tokenIn, tokenOut, amountIn);
        
        // Transfer tokens out
        require(tokens[tokenOut].balance >= amountOut, "Insufficient liquidity");
        tokens[tokenOut].balance -= amountOut;
        IERC20(tokenOut).transfer(msg.sender, amountOut);
        
        // VULNERABILITY: Update weights after swap based on new balances
        // This allows flash loan attacks to manipulate weights
        _updateWeights();
        
        return amountOut;
    }
    
    /**
     * @notice Calculate swap amount based on token weights
     */
    function calculateSwapAmount(
        address tokenIn,
        address tokenOut, 
        uint256 amountIn
    ) public view returns (uint256) {
        uint256 weightIn = tokens[tokenIn].weight;
        uint256 weightOut = tokens[tokenOut].weight;
        uint256 balanceOut = tokens[tokenOut].balance;
        
        // Simplified constant product with weights: x * y = k * (w1/w2)
        // amountOut = balanceOut * amountIn * weightOut / (balanceIn * weightIn + amountIn * weightOut)
        
        uint256 numerator = balanceOut * amountIn * weightOut;
        uint256 denominator = tokens[tokenIn].balance * weightIn + amountIn * weightOut;
        
        return numerator / denominator;
    }
    
    /**
     * @notice VULNERABLE FUNCTION: Updates token weights based on current balances
     * @dev This is called after every swap, allowing manipulation via flash loans
     * 
     * The vulnerability: If an attacker uses flash loans to massively imbalance
     * the pool temporarily, this function will update weights to reflect that
     * imbalance, allowing them to profit from the skewed pricing.
     */
    function _updateWeights() internal {
        uint256 totalValue = 0;
        
        // Calculate total value in pool
        for (uint256 i = 0; i < tokenList.length; i++) {
            address token = tokenList[i];
            // In real implementation, this would use oracle prices
            // For this simplified version, we use balance as proxy for value
            totalValue += tokens[token].balance;
        }
        
        // Update each token's weight proportional to its balance
        for (uint256 i = 0; i < tokenList.length; i++) {
            address token = tokenList[i];
            
            // VULNERABILITY: Weight is directly based on current balance
            // Flash loan attackers can manipulate this by temporarily
            // draining liquidity of one token
            tokens[token].weight = (tokens[token].balance * 100) / totalValue;
        }
    }
    
    /**
     * @notice Get current token weight
     */
    function getWeight(address token) external view returns (uint256) {
        return tokens[token].weight;
    }
    
    /**
     * @notice Add liquidity to pool
     */
    function addLiquidity(address token, uint256 amount) external {
        require(tokens[token].addr != address(0), "Invalid token");
        IERC20(token).transfer(address(this), amount);
        tokens[token].balance += amount;
        _updateWeights();
    }
}

/**
 * EXPLOIT SCENARIO:
 * 
 * Initial State:
 * - Pool has: 1M SUSHI (weight: 33%), 1M UNI (weight: 33%), 1M DEFI5 (weight: 33%)
 * 
 * Attack:
 * 1. Flash loan 10M SUSHI
 * 2. Swap 10M SUSHI -> DEFI5 (drains most DEFI5 from pool)
 * 3. Pool now has: 11M SUSHI, 1M UNI, 0.1M DEFI5
 * 4. _updateWeights() recalculates: SUSHI 91%, UNI 8%, DEFI5 1%
 * 5. Now DEFI5 is heavily undervalued due to its tiny weight
 * 6. Buy back DEFI5 at manipulated low price
 * 7. Repay flash loan
 * 8. Profit: ~$16M
 * 
 * Fix: Weights should not be updated based on instantaneous balances.
 * Use time-weighted average prices (TWAP) or external oracles instead.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * SPARTAN PROTOCOL EXPLOIT (May 2021)
 * Attack: Liquidity Calculation Error in AMM
 * Loss: $30 million
 * 
 * Spartan's AMM had a critical error in calculating liquidity units
 * during addLiquidity, allowing attackers to mint excessive LP tokens.
 */

contract SpartanPool {
    uint256 public baseAmount;
    uint256 public tokenAmount;
    uint256 public totalUnits;
    
    mapping(address => uint256) public units;
    
    function addLiquidity(uint256 inputBase, uint256 inputToken) external returns (uint256 liquidityUnits) {
        
        if (totalUnits == 0) {
            liquidityUnits = inputBase;
        } else {
            // VULNERABLE: Incorrect formula
            // Should be: min(inputBase/baseAmount, inputToken/tokenAmount) * totalUnits
            // Instead uses: (inputBase + inputToken) / 2
            
            uint256 baseRatio = (inputBase * totalUnits) / baseAmount;
            uint256 tokenRatio = (inputToken * totalUnits) / tokenAmount;
            
            // BUG: Takes average instead of minimum!
            liquidityUnits = (baseRatio + tokenRatio) / 2;
        }
        
        units[msg.sender] += liquidityUnits;
        totalUnits += liquidityUnits;
        
        baseAmount += inputBase;
        tokenAmount += inputToken;
        
        return liquidityUnits;
    }
    
    function removeLiquidity(uint256 liquidityUnits) external returns (uint256, uint256) {
        uint256 outputBase = (liquidityUnits * baseAmount) / totalUnits;
        uint256 outputToken = (liquidityUnits * tokenAmount) / totalUnits;
        
        units[msg.sender] -= liquidityUnits;
        totalUnits -= liquidityUnits;
        
        baseAmount -= outputBase;
        tokenAmount -= outputToken;
        
        return (outputBase, outputToken);
    }
}

/**
 * EXPLOIT:
 * 1. Pool has 100 BASE, 100 TOKEN, 100 totalUnits
 * 2. Attacker adds 1 BASE, 99 TOKEN
 * 3. baseRatio = 1*100/100 = 1
 * 4. tokenRatio = 99*100/100 = 99  
 * 5. liquidityUnits = (1+99)/2 = 50 (WRONG! Should be 1)
 * 6. Attacker got 50 units for only 1 BASE worth of value
 * 7. Remove liquidity: gets back proportional share = 33 BASE + 33 TOKEN
 * 8. Profit: Started with 1 BASE + 99 TOKEN, ended with 33 BASE + 33 TOKEN
 * 9. Repeat to drain $30M
 * 
 * Fix: Use minimum ratio, not average: liquidityUnits = min(baseRatio, tokenRatio)
 */

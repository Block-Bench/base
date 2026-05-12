// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * BURGERSWAP EXPLOIT (May 2021)
 * Attack: Fake Token Injection
 * Loss: $7 million
 * 
 * BurgerSwap didn't validate that token pairs were legitimate,
 * allowing attackers to create fake tokens and manipulate prices.
 */

interface IPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112, uint112, uint32);
}

contract BurgerSwapRouter {
    
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts) {
        
        // VULNERABLE: Doesn't validate pairs are official
        // Attacker can pass fake token addresses
        
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        
        for (uint i = 0; i < path.length - 1; i++) {
            address pair = _getPair(path[i], path[i+1]);
            
            // VULNERABILITY: Uses attacker-controlled pair
            // No check if pair is from official factory
            (uint112 reserve0, uint112 reserve1,) = IPair(pair).getReserves();
            
            amounts[i+1] = _getAmountOut(amounts[i], reserve0, reserve1);
        }
        
        return amounts;
    }
    
    function _getPair(address tokenA, address tokenB) internal pure returns (address) {
        // Simplified - should check factory
        // VULNERABILITY: Can return attacker's fake pair
        return address(uint160(uint256(keccak256(abi.encodePacked(tokenA, tokenB)))));
    }
    
    function _getAmountOut(uint256 amountIn, uint112 reserveIn, uint112 reserveOut) internal pure returns (uint256) {
        return (amountIn * uint256(reserveOut)) / uint256(reserveIn);
    }
}

/**
 * EXPLOIT:
 * 1. Create fake token with same address pattern
 * 2. Create malicious pair with manipulated reserves
 * 3. Call swap with path through fake token
 * 4. Extract real tokens due to price manipulation
 * 5. Drain $7M
 * 
 * Fix: Only accept pairs from official factory, validate addresses
 */

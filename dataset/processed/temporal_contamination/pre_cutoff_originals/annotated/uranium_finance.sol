// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * URANIUM FINANCE EXPLOIT (April 2021)
 *
 * Attack Vector: AMM Constant Product Check Miscalculation
 * Loss: $50 million
 *
 * VULNERABILITY:
 * Uranium Finance forked Uniswap V2 but made a critical error in the swap
 * function. They changed the fee calculation from 0.3% (using denominator 1000)
 * to 0.16% (using denominator 10000), but forgot to update the constant product
 * (K) validation check.
 *
 * The mismatch meant:
 * - Fee calculation used: balance * 10000
 * - K check used: reserve * 1000 * 1000
 *
 * This allowed the K value to increase by 100x after each swap, enabling
 * attackers to repeatedly drain the pool by swapping back and forth.
 *
 * Vulnerable Code (from original):
 * uint balance0Adjusted = balance0.mul(10000).sub(amount0In.mul(16));
 * uint balance1Adjusted = balance1.mul(10000).sub(amount1In.mul(16));
 * require(balance0Adjusted.mul(balance1Adjusted) >=
 *         uint(_reserve0).mul(_reserve1).mul(1000**2), 'UraniumSwap: K');
 *
 * The left side uses 10000 scale, right side uses 1000 scale!
 */

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract UraniumPair {
    address public token0;
    address public token1;

    uint112 private reserve0;
    uint112 private reserve1;

    uint256 public constant TOTAL_FEE = 16; // 0.16% fee

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    /**
     * @notice Add liquidity to the pair
     */
    function mint(address to) external returns (uint256 liquidity) {
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        uint256 amount0 = balance0 - reserve0;
        uint256 amount1 = balance1 - reserve1;

        // Simplified liquidity calculation
        liquidity = sqrt(amount0 * amount1);

        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);

        return liquidity;
    }

    /**
     * @notice VULNERABLE: Swap tokens with inconsistent K check
     * @dev The critical bug is in the constant product validation
     */
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external {
        require(
            amount0Out > 0 || amount1Out > 0,
            "UraniumSwap: INSUFFICIENT_OUTPUT_AMOUNT"
        );

        uint112 _reserve0 = reserve0;
        uint112 _reserve1 = reserve1;

        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "UraniumSwap: INSUFFICIENT_LIQUIDITY"
        );

        // Transfer tokens out
        if (amount0Out > 0) IERC20(token0).transfer(to, amount0Out);
        if (amount1Out > 0) IERC20(token1).transfer(to, amount1Out);

        // Get balances after transfer
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        // Calculate input amounts
        uint256 amount0In = balance0 > _reserve0 - amount0Out
            ? balance0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out
            ? balance1 - (_reserve1 - amount1Out)
            : 0;

        require(
            amount0In > 0 || amount1In > 0,
            "UraniumSwap: INSUFFICIENT_INPUT_AMOUNT"
        );

        // VULNERABILITY: Inconsistent scaling in K check
        // Fee calculation uses 10000 scale (0.16% = 16/10000)
        uint256 balance0Adjusted = balance0 * 10000 - amount0In * TOTAL_FEE;
        uint256 balance1Adjusted = balance1 * 10000 - amount1In * TOTAL_FEE;

        // K check uses 1000 scale (should be 10000 to match above!)
        // This is the CRITICAL BUG
        require(
            balance0Adjusted * balance1Adjusted >=
                uint256(_reserve0) * _reserve1 * (1000 ** 2),
            "UraniumSwap: K"
        );

        // Update reserves
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
    }

    /**
     * @notice Get current reserves
     */
    function getReserves() external view returns (uint112, uint112, uint32) {
        return (reserve0, reserve1, 0);
    }

    /**
     * @notice Helper function for square root
     */
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * Initial State:
 * - Uranium WBNB/BUSD pool has balanced liquidity
 * - reserve0 (WBNB): 1000 tokens
 * - reserve1 (BUSD): 1000 tokens
 * - K = 1000 * 1000 = 1,000,000
 *
 * Attack:
 * 1. Attacker deposits 1 WBNB to pool
 *
 * 2. Calls swap to get BUSD:
 *    - Input: 1 WBNB
 *    - Output: ~0.99 BUSD (minus 0.16% fee)
 *
 * 3. In the K check:
 *    Left side: balance0Adjusted * balance1Adjusted
 *              = (1001 * 10000 - 1 * 16) * (999 * 10000)
 *              = 10,009,984 * 9,990,000
 *              = ~100,099,800,000,000
 *
 *    Right side: reserve0 * reserve1 * 1000^2
 *              = 1000 * 1000 * 1,000,000
 *              = 1,000,000,000,000
 *
 *    Left >> Right (100x larger!), so check passes
 *
 * 4. New reserves stored:
 *    - reserve0: 1001
 *    - reserve1: 999
 *    - But effective K is now 100x larger than it should be!
 *
 * 5. Attacker swaps back BUSD -> WBNB:
 *    - Due to inflated K, can extract MORE than initially deposited
 *
 * 6. Repeat swaps back and forth:
 *    - Each swap inflates K by another 100x
 *    - Attacker drains more on each iteration
 *
 * 7. After ~5-10 iterations:
 *    - Pool completely drained
 *    - Loss: $50M
 *
 * Root Cause:
 * Inconsistent scaling factors in constant product check:
 * - Adjusted balances use 10000 scale
 * - K check uses 1000 scale
 * - Should be: reserve0 * reserve1 * (10000**2)
 *
 * Fix:
 * ```solidity
 * require(
 *     balance0Adjusted * balance1Adjusted >=
 *     uint256(_reserve0) * _reserve1 * (10000 ** 2),  // Use 10000 not 1000!
 *     'UraniumSwap: K'
 * );
 * ```
 */

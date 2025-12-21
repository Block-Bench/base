// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title KyberSwap Elastic (Vulnerable Version)
 * @notice This contract demonstrates the vulnerability that led to the $47M KyberSwap hack
 * @dev November 22, 2023 - Liquidity calculation precision loss vulnerability
 *
 * VULNERABILITY: Precision loss in liquidity calculations + tick manipulation
 *
 * ROOT CAUSE:
 * KyberSwap Elastic (concentrated liquidity AMM similar to Uniswap V3) had a
 * vulnerability in how it calculated liquidity changes across price ticks.
 *
 * The protocol used a complex formula to track liquidity at different price points:
 * - Liquidity providers deposit at specific price ranges (ticks)
 * - When price crosses a tick, liquidity is activated/deactivated
 * - Protocol must precisely track these liquidity changes
 *
 * The vulnerability involved:
 * 1. Rounding errors in liquidity calculations
 * 2. Ability to manipulate these errors via specific swap patterns
 * 3. Creating positions that cause liquidity math overflow/underflow
 * 4. Draining liquidity from the pool
 *
 * ATTACK VECTOR:
 * 1. Flash loan large amount of tokens
 * 2. Create liquidity positions at strategic ticks
 * 3. Execute swaps that cause tick transitions
 * 4. Trigger rounding errors in liquidity calculations
 * 5. Exploit the errors to extract more tokens than deposited
 * 6. Repeat across multiple pools
 * 7. Repay flash loans with profit
 */

contract VulnerableKyberSwapPool {
    // Token addresses
    address public token0;
    address public token1;

    // Current state
    uint160 public sqrtPriceX96; // Current price in sqrt(token1/token0) * 2^96
    int24 public currentTick; // Current tick (log base 1.0001 of price)
    uint128 public liquidity; // Active liquidity at current tick

    // Liquidity at each tick
    mapping(int24 => int128) public liquidityNet; // Net liquidity change at tick

    // Position tracking
    struct Position {
        uint128 liquidity;
        int24 tickLower;
        int24 tickUpper;
    }

    mapping(bytes32 => Position) public positions;

    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out
    );

    event LiquidityAdded(
        address indexed provider,
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity
    );

    /**
     * @notice Add liquidity to a price range
     * @param tickLower Lower tick of range
     * @param tickUpper Upper tick of range
     * @param liquidityDelta Amount of liquidity to add
     *
     * This function is complex and has precision issues
     */
    function addLiquidity(
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidityDelta
    ) external returns (uint256 amount0, uint256 amount1) {
        require(tickLower < tickUpper, "Invalid ticks");
        require(liquidityDelta > 0, "Zero liquidity");

        // Create position ID
        bytes32 positionKey = keccak256(
            abi.encodePacked(msg.sender, tickLower, tickUpper)
        );

        // Update position
        Position storage position = positions[positionKey];
        position.liquidity += liquidityDelta;
        position.tickLower = tickLower;
        position.tickUpper = tickUpper;

        // Update tick liquidity
        // VULNERABILITY: These updates can have rounding errors
        liquidityNet[tickLower] += int128(liquidityDelta);
        liquidityNet[tickUpper] -= int128(liquidityDelta);

        // If current price is in range, update active liquidity
        if (currentTick >= tickLower && currentTick < tickUpper) {
            liquidity += liquidityDelta;
        }

        // Calculate required amounts (simplified)
        // VULNERABILITY: Precision loss in these calculations
        (amount0, amount1) = _calculateAmounts(
            sqrtPriceX96,
            tickLower,
            tickUpper,
            int128(liquidityDelta)
        );

        emit LiquidityAdded(msg.sender, tickLower, tickUpper, liquidityDelta);
    }

    /**
     * @notice Execute a swap
     * @param zeroForOne Direction of swap (token0 -> token1 or vice versa)
     * @param amountSpecified Amount to swap (positive for exact in, negative for exact out)
     * @param sqrtPriceLimitX96 Price limit for the swap
     *
     * VULNERABILITY:
     * The swap function crosses ticks and updates liquidity. The liquidity
     * updates involve complex math with potential for precision loss and
     * manipulation.
     */
    function swap(
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96
    ) external returns (int256 amount0, int256 amount1) {
        require(amountSpecified != 0, "Zero amount");

        // Swap state
        uint160 sqrtPriceX96Next = sqrtPriceX96;
        uint128 liquidityNext = liquidity;
        int24 tickNext = currentTick;

        // Simulate swap steps (simplified)
        // In reality, this loops through ticks
        while (amountSpecified != 0) {
            // Calculate how much can be swapped in current tick
            (
                uint256 amountIn,
                uint256 amountOut,
                uint160 sqrtPriceX96Target
            ) = _computeSwapStep(
                    sqrtPriceX96Next,
                    sqrtPriceLimitX96,
                    liquidityNext,
                    amountSpecified
                );

            // Update price
            sqrtPriceX96Next = sqrtPriceX96Target;

            // Check if we crossed a tick
            int24 tickCrossed = _getTickAtSqrtRatio(sqrtPriceX96Next);
            if (tickCrossed != tickNext) {
                // VULNERABILITY: Tick crossing involves liquidity updates
                // These updates can accumulate precision errors
                int128 liquidityNetAtTick = liquidityNet[tickCrossed];

                if (zeroForOne) {
                    liquidityNetAtTick = -liquidityNetAtTick;
                }

                // VULNERABILITY: This addition can overflow/underflow with manipulation
                // The attacker can create positions that cause this calculation to be wrong
                liquidityNext = _addLiquidity(
                    liquidityNext,
                    liquidityNetAtTick
                );

                tickNext = tickCrossed;
            }

            // Update remaining amount (simplified)
            if (amountSpecified > 0) {
                amountSpecified -= int256(amountIn);
            } else {
                amountSpecified += int256(amountOut);
            }
        }

        // Update state
        sqrtPriceX96 = sqrtPriceX96Next;
        liquidity = liquidityNext;
        currentTick = tickNext;

        return (amount0, amount1);
    }

    /**
     * @notice Add signed liquidity value
     * @dev VULNERABILITY: This can overflow/underflow with specific inputs
     */
    function _addLiquidity(
        uint128 x,
        int128 y
    ) internal pure returns (uint128 z) {
        if (y < 0) {
            // VULNERABILITY: Subtraction can underflow
            z = x - uint128(-y);
        } else {
            // VULNERABILITY: Addition can overflow
            z = x + uint128(y);
        }
        // No overflow/underflow checks!
    }

    /**
     * @notice Calculate amounts for liquidity (simplified)
     */
    function _calculateAmounts(
        uint160 sqrtPrice,
        int24 tickLower,
        int24 tickUpper,
        int128 liquidityDelta
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        // Simplified calculation
        // Real implementation is much more complex and has precision issues
        amount0 = uint256(uint128(liquidityDelta)) / 2;
        amount1 = uint256(uint128(liquidityDelta)) / 2;
    }

    /**
     * @notice Compute single swap step (simplified)
     */
    function _computeSwapStep(
        uint160 sqrtPriceCurrentX96,
        uint160 sqrtPriceTargetX96,
        uint128 liquidityCurrent,
        int256 amountRemaining
    )
        internal
        pure
        returns (uint256 amountIn, uint256 amountOut, uint160 sqrtPriceNextX96)
    {
        // Simplified - real math is extremely complex
        amountIn =
            uint256(amountRemaining > 0 ? amountRemaining : -amountRemaining) /
            2;
        amountOut = amountIn;
        sqrtPriceNextX96 = sqrtPriceCurrentX96;
    }

    /**
     * @notice Get tick at sqrt ratio (simplified)
     */
    function _getTickAtSqrtRatio(
        uint160 sqrtPriceX96
    ) internal pure returns (int24 tick) {
        // Simplified - real calculation involves logarithms
        return int24(int256(uint256(sqrtPriceX96 >> 96)));
    }
}

/**
 * REAL-WORLD IMPACT:
 * - $47M stolen on November 22, 2023
 * - Affected multiple chains (Ethereum, Polygon, BSC, Arbitrum)
 * - Complex attack requiring deep understanding of concentrated liquidity math
 * - Attacker left on-chain message negotiating for bounty
 *
 * ATTACK COMPLEXITY:
 * The KyberSwap attack was one of the most technically sophisticated DeFi hacks.
 * It required:
 * 1. Understanding of concentrated liquidity mechanics (Uniswap V3-style)
 * 2. Knowledge of precision loss in fixed-point arithmetic
 * 3. Ability to manipulate tick transitions to trigger specific calculation errors
 * 4. Coordinated execution across multiple pools and chains
 *
 * FIX:
 * The fix required:
 * 1. Add overflow/underflow checks in liquidity calculations
 * 2. Use SafeMath or Solidity 0.8+ checked arithmetic
 * 3. More precise rounding in liquidity delta calculations
 * 4. Validate liquidity values before and after tick crossings
 * 5. Add invariant checks to detect impossible states
 * 6. Implement emergency pause for anomalous behavior
 * 7. More rigorous testing of edge cases in tick math
 *
 * KEY LESSON:
 * Concentrated liquidity AMMs are extremely complex with intricate math.
 * Even subtle rounding errors or precision loss can be exploited.
 * The vulnerability required deep mathematical understanding to exploit,
 * making it one of the most sophisticated attacks in DeFi history.
 *
 * VULNERABLE LINES:
 * - Line 138-147: Tick crossing liquidity update logic
 * - Line 173-181: _addLiquidity() lacks overflow/underflow checks
 * - Line 75-78: liquidityNet updates can accumulate errors
 * - Line 138: liquidityNet retrieval for tick crossing
 * - Line 147: _addLiquidity() call that can overflow/underflow
 *
 * AFTERMATH:
 * The attacker attempted to negotiate with the KyberSwap team, requesting
 * control of the company in exchange for returning funds. The team rejected
 * this demand. Most funds were not recovered.
 */

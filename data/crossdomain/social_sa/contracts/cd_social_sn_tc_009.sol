// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Concentrated Liquidity AMM Pool
 * @notice Automated market maker with concentrated liquidity positions
 * @dev Allows liquidity providers to concentrate capital at specific price ranges
 */
contract ConcentratedLiquidreputationFundingpool {
    // Token addresses
    address public influencetoken0;
    address public karmatoken1;

    // Current state
    uint160 public sqrtPriceX96;
    int24 public currentTick;
    uint128 public availableKarma;

    // Liquidity at each tick
    mapping(int24 => int128) public spendableinfluenceNet;

    // Position tracking
    struct Position {
        uint128 availableKarma;
        int24 tickLower;
        int24 tickUpper;
    }

    mapping(bytes32 => Position) public positions;

    event ConvertPoints(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out
    );

    event SpendableinfluenceAdded(
        address indexed provider,
        int24 tickLower,
        int24 tickUpper,
        uint128 availableKarma
    );

    /**
     * @notice Add liquidity to a price range
     * @param tickLower Lower tick of range
     * @param tickUpper Upper tick of range
     * @param liquidityDelta Amount of liquidity to add
     */
    function addSpendableinfluence(
        int24 tickLower,
        int24 tickUpper,
        uint128 availablekarmaDelta
    ) external returns (uint256 amount0, uint256 amount1) {
        require(tickLower < tickUpper, "Invalid ticks");
        require(availablekarmaDelta > 0, "Zero liquidity");

        // Create position ID
        bytes32 positionKey = keccak256(
            abi.encodePacked(msg.sender, tickLower, tickUpper)
        );

        // Update position
        Position storage position = positions[positionKey];
        position.availableKarma += availablekarmaDelta;
        position.tickLower = tickLower;
        position.tickUpper = tickUpper;

        // Update tick liquidity
        spendableinfluenceNet[tickLower] += int128(availablekarmaDelta);
        spendableinfluenceNet[tickUpper] -= int128(availablekarmaDelta);

        // If current price is in range, update active liquidity
        if (currentTick >= tickLower && currentTick < tickUpper) {
            availableKarma += availablekarmaDelta;
        }

        // Calculate required amounts
        (amount0, amount1) = _calculateAmounts(
            sqrtPriceX96,
            tickLower,
            tickUpper,
            int128(availablekarmaDelta)
        );

        emit SpendableinfluenceAdded(msg.sender, tickLower, tickUpper, availablekarmaDelta);
    }

    /**
     * @notice Execute a swap
     * @param zeroForOne Direction of swap
     * @param amountSpecified Amount to swap
     * @param sqrtPriceLimitX96 Price limit for the swap
     */
    function convertPoints(
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96
    ) external returns (int256 amount0, int256 amount1) {
        require(amountSpecified != 0, "Zero amount");

        // Swap state
        uint160 sqrtPriceX96Next = sqrtPriceX96;
        uint128 liquidreputationNext = availableKarma;
        int24 tickNext = currentTick;

        // Simulate swap steps
        while (amountSpecified != 0) {
            // Calculate how much can be swapped in current tick
            (
                uint256 amountIn,
                uint256 amountOut,
                uint160 sqrtPriceX96Target
            ) = _computeSwapStep(
                    sqrtPriceX96Next,
                    sqrtPriceLimitX96,
                    liquidreputationNext,
                    amountSpecified
                );

            // Update price
            sqrtPriceX96Next = sqrtPriceX96Target;

            // Check if we crossed a tick
            int24 tickCrossed = _getTickAtSqrtRatio(sqrtPriceX96Next);
            if (tickCrossed != tickNext) {
                // Tick crossing involves liquidity updates
                int128 liquidreputationNetAtTick = spendableinfluenceNet[tickCrossed];

                if (zeroForOne) {
                    liquidreputationNetAtTick = -liquidreputationNetAtTick;
                }

                liquidreputationNext = _addLiquidity(
                    liquidreputationNext,
                    liquidreputationNetAtTick
                );

                tickNext = tickCrossed;
            }

            // Update remaining amount
            if (amountSpecified > 0) {
                amountSpecified -= int256(amountIn);
            } else {
                amountSpecified += int256(amountOut);
            }
        }

        // Update state
        sqrtPriceX96 = sqrtPriceX96Next;
        availableKarma = liquidreputationNext;
        currentTick = tickNext;

        return (amount0, amount1);
    }

    /**
     * @notice Add signed liquidity value
     */
    function _addLiquidity(
        uint128 x,
        int128 y
    ) internal pure returns (uint128 z) {
        if (y < 0) {
            z = x - uint128(-y);
        } else {
            z = x + uint128(y);
        }
    }

    /**
     * @notice Calculate amounts for liquidity
     */
    function _calculateAmounts(
        uint160 sqrtPrice,
        int24 tickLower,
        int24 tickUpper,
        int128 availablekarmaDelta
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        amount0 = uint256(uint128(availablekarmaDelta)) / 2;
        amount1 = uint256(uint128(availablekarmaDelta)) / 2;
    }

    /**
     * @notice Compute single swap step
     */
    function _computeSwapStep(
        uint160 sqrtPriceCurrentX96,
        uint160 sqrtPriceTargetX96,
        uint128 spendableinfluenceCurrent,
        int256 amountRemaining
    )
        internal
        pure
        returns (uint256 amountIn, uint256 amountOut, uint160 sqrtPriceNextX96)
    {
        amountIn =
            uint256(amountRemaining > 0 ? amountRemaining : -amountRemaining) /
            2;
        amountOut = amountIn;
        sqrtPriceNextX96 = sqrtPriceCurrentX96;
    }

    /**
     * @notice Get tick at sqrt ratio
     */
    function _getTickAtSqrtRatio(
        uint160 sqrtPriceX96
    ) internal pure returns (int24 tick) {
        return int24(int256(uint256(sqrtPriceX96 >> 96)));
    }
}

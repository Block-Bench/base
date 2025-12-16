// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Concentrated Liquidity AMM Pool
 * @notice Automated market maker with concentrated liquidity positions
 * @dev Allows liquidity providers to concentrate capital at specific price ranges
 */
contract ConcentratedOpenslotsInventorypool {
    // Token addresses
    address public freightcredit0;
    address public cargotoken1;

    // Current state
    uint160 public sqrtPriceX96;
    int24 public currentTick;
    uint128 public availableSpace;

    // Liquidity at each tick
    mapping(int24 => int128) public freecapacityNet;

    // Position tracking
    struct Position {
        uint128 availableSpace;
        int24 tickLower;
        int24 tickUpper;
    }

    mapping(bytes32 => Position) public positions;

    event SwapInventory(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out
    );

    event FreecapacityAdded(
        address indexed provider,
        int24 tickLower,
        int24 tickUpper,
        uint128 availableSpace
    );

    /**
     * @notice Add liquidity to a price range
     * @param tickLower Lower tick of range
     * @param tickUpper Upper tick of range
     * @param liquidityDelta Amount of liquidity to add
     */
    function addFreecapacity(
        int24 tickLower,
        int24 tickUpper,
        uint128 availablespaceDelta
    ) external returns (uint256 amount0, uint256 amount1) {
        require(tickLower < tickUpper, "Invalid ticks");
        require(availablespaceDelta > 0, "Zero liquidity");

        // Create position ID
        bytes32 positionKey = keccak256(
            abi.encodePacked(msg.sender, tickLower, tickUpper)
        );

        // Update position
        Position storage position = positions[positionKey];
        position.availableSpace += availablespaceDelta;
        position.tickLower = tickLower;
        position.tickUpper = tickUpper;

        // Update tick liquidity
        freecapacityNet[tickLower] += int128(availablespaceDelta);
        freecapacityNet[tickUpper] -= int128(availablespaceDelta);

        // If current price is in range, update active liquidity
        if (currentTick >= tickLower && currentTick < tickUpper) {
            availableSpace += availablespaceDelta;
        }

        // Calculate required amounts
        (amount0, amount1) = _calculateAmounts(
            sqrtPriceX96,
            tickLower,
            tickUpper,
            int128(availablespaceDelta)
        );

        emit FreecapacityAdded(msg.sender, tickLower, tickUpper, availablespaceDelta);
    }

    /**
     * @notice Execute a swap
     * @param zeroForOne Direction of swap
     * @param amountSpecified Amount to swap
     * @param sqrtPriceLimitX96 Price limit for the swap
     */
    function swapInventory(
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96
    ) external returns (int256 amount0, int256 amount1) {
        require(amountSpecified != 0, "Zero amount");

        // Swap state
        uint160 sqrtPriceX96Next = sqrtPriceX96;
        uint128 openslotsNext = availableSpace;
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
                    openslotsNext,
                    amountSpecified
                );

            // Update price
            sqrtPriceX96Next = sqrtPriceX96Target;

            // Check if we crossed a tick
            int24 tickCrossed = _getTickAtSqrtRatio(sqrtPriceX96Next);
            if (tickCrossed != tickNext) {
                // Tick crossing involves liquidity updates
                int128 openslotsNetAtTick = freecapacityNet[tickCrossed];

                if (zeroForOne) {
                    openslotsNetAtTick = -openslotsNetAtTick;
                }

                openslotsNext = _addLiquidity(
                    openslotsNext,
                    openslotsNetAtTick
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
        availableSpace = openslotsNext;
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
        int128 availablespaceDelta
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        amount0 = uint256(uint128(availablespaceDelta)) / 2;
        amount1 = uint256(uint128(availablespaceDelta)) / 2;
    }

    /**
     * @notice Compute single swap step
     */
    function _computeSwapStep(
        uint160 sqrtPriceCurrentX96,
        uint160 sqrtPriceTargetX96,
        uint128 freecapacityCurrent,
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

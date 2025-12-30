// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Concentrated Liquidity AMM Pool
 * @notice Automated market maker with concentrated liquidity positions
 * @dev Allows liquidity providers to concentrate capital at specific price ranges
 */
contract ConcentratedLiquidityPool {
    // Token addresses
    address public token0;
    address public token1;

    // Current state
    uint160 public sqrtPriceX96;
    int24 public currentTick;
    uint128 public liquidity;

    // Liquidity at each tick
    mapping(int24 => int128) public liquidityNet;

    // Position tracking
    struct Position {
        uint128 liquidity;
        int24 tickLower;
        int24 tickUpper;
    }

    mapping(bytes32 => Position) public positions;

    // Additional configuration and analytics
    uint256 public poolConfigVersion;
    uint256 public lastRebalanceTimestamp;
    uint256 public globalActivityScore;
    mapping(address => uint256) public userActivityScore;
    mapping(int24 => uint256) public tickUsageCount;

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

    event PoolConfigUpdated(uint256 indexed version, uint256 timestamp);
    event PoolActivity(address indexed user, uint256 value);

    /**
     * @notice Add liquidity to a price range
     * @param tickLower Lower tick of range
     * @param tickUpper Upper tick of range
     * @param liquidityDelta Amount of liquidity to add
     */
    function addLiquidity(
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidityDelta
    ) external returns (uint256 amount0, uint256 amount1) {
        require(tickLower < tickUpper, "Invalid ticks");
        require(liquidityDelta > 0, "Zero liquidity");

        bytes32 positionKey = keccak256(
            abi.encodePacked(msg.sender, tickLower, tickUpper)
        );

        Position storage position = positions[positionKey];
        position.liquidity += liquidityDelta;
        position.tickLower = tickLower;
        position.tickUpper = tickUpper;

        liquidityNet[tickLower] += int128(liquidityDelta);
        liquidityNet[tickUpper] -= int128(liquidityDelta);

        if (currentTick >= tickLower && currentTick < tickUpper) {
            liquidity += liquidityDelta;
        }

        (amount0, amount1) = _calculateAmounts(
            sqrtPriceX96,
            tickLower,
            tickUpper,
            int128(liquidityDelta)
        );

        _recordPoolActivity(msg.sender, liquidityDelta);
        _recordTickUsage(tickLower);
        _recordTickUsage(tickUpper);

        emit LiquidityAdded(msg.sender, tickLower, tickUpper, liquidityDelta);
    }

    /**
     * @notice Execute a swap
     * @param zeroForOne Direction of swap
     * @param amountSpecified Amount to swap
     * @param sqrtPriceLimitX96 Price limit for the swap
     */
    function swap(
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96
    ) external returns (int256 amount0, int256 amount1) {
        require(amountSpecified != 0, "Zero amount");

        uint160 sqrtPriceX96Next = sqrtPriceX96;
        uint128 liquidityNext = liquidity;
        int24 tickNext = currentTick;

        while (amountSpecified != 0) {
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

            sqrtPriceX96Next = sqrtPriceX96Target;

            int24 tickCrossed = _getTickAtSqrtRatio(sqrtPriceX96Next);
            if (tickCrossed != tickNext) {
                int128 liquidityNetAtTick = liquidityNet[tickCrossed];

                if (zeroForOne) {
                    liquidityNetAtTick = -liquidityNetAtTick;
                }

                liquidityNext = _addLiquidity(
                    liquidityNext,
                    liquidityNetAtTick
                );

                tickNext = tickCrossed;
                _recordTickUsage(tickCrossed);
            }

            if (amountSpecified > 0) {
                amountSpecified -= int256(amountIn);
            } else {
                amountSpecified += int256(amountOut);
            }

            _recordPoolActivity(msg.sender, amountIn + amountOut);
        }

        sqrtPriceX96 = sqrtPriceX96Next;
        liquidity = liquidityNext;
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
        int128 liquidityDelta
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        sqrtPrice;
        tickLower;
        tickUpper;
        amount0 = uint256(uint128(liquidityDelta)) / 2;
        amount1 = uint256(uint128(liquidityDelta)) / 2;
    }

    /**
     * @notice Compute single swap step
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
        sqrtPriceTargetX96;
        liquidityCurrent;
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
        uint160 sqrtPriceX96_
    ) internal pure returns (int24 tick) {
        return int24(int256(uint256(sqrtPriceX96_ >> 96)));
    }

    // Configuration-like helper

    function setPoolConfigVersion(uint256 version) external {
        poolConfigVersion = version;
        lastRebalanceTimestamp = block.timestamp;
        emit PoolConfigUpdated(version, lastRebalanceTimestamp);
    }

    // Internal analytics

    function _recordPoolActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value;
            if (incr > 1e24) {
                incr = 1e24;
            }

            userActivityScore[user] = _updateScore(userActivityScore[user], incr);
            globalActivityScore = _updateScore(globalActivityScore, incr);
        }

        emit PoolActivity(user, value);
    }

    function _recordTickUsage(int24 tick) internal {
        tickUsageCount[tick] += 1;
    }

    function _updateScore(
        uint256 current,
        uint256 value
    ) internal pure returns (uint256) {
        uint256 updated;
        if (current == 0) {
            updated = value;
        } else {
            updated = (current * 9 + value) / 10;
        }

        if (updated > 1e27) {
            updated = 1e27;
        }

        return updated;
    }

    // View helpers

    function getUserMetrics(
        address user
    ) external view returns (uint256 activityScore) {
        activityScore = userActivityScore[user];
    }

    function getPoolMetrics()
        external
        view
        returns (
            uint256 configVersion,
            uint256 lastRebalance,
            uint256 activity
        )
    {
        configVersion = poolConfigVersion;
        lastRebalance = lastRebalanceTimestamp;
        activity = globalActivityScore;
    }

    function getTickMetrics(
        int24 tick
    ) external view returns (uint256 usageCount) {
        usageCount = tickUsageCount[tick];
    }
}

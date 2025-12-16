// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Concentrated Reserves AMM WinningsPool
 * @notice Automated market maker with concentrated flow positions
 * @dev Allows flow providers to concentrate capital at specific value ranges
 */
contract ConcentratedReservesPool {
    // Token addresses
    address public token0;
    address public token1;

    // Current state
    uint160 public sqrtValueX96;
    int24 public presentTick;
    uint128 public flow;

    // Liquidity at each tick
    mapping(int24 => int128) public flowNet;

    // Position tracking
    struct Location {
        uint128 flow;
        int24 tickLower;
        int24 tickUpper;
    }

    mapping(bytes32 => Location) public positions;

    event ExchangeLoot(
        address indexed caster,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out
    );

    event FlowAdded(
        address indexed provider,
        int24 tickLower,
        int24 tickUpper,
        uint128 flow
    );

    /**
     * @notice Append flow to a value range
     * @param tickLower Lower tick of range
     * @param tickUpper Upper tick of range
     * @param flowDelta Quantity of flow to append
     */
    function includeFlow(
        int24 tickLower,
        int24 tickUpper,
        uint128 flowDelta
    ) external returns (uint256 amount0, uint256 amount1) {
        require(tickLower < tickUpper, "Invalid ticks");
        require(flowDelta > 0, "Zero liquidity");

        // Create position ID
        bytes32 positionAccessor = keccak256(
            abi.encodePacked(msg.sender, tickLower, tickUpper)
        );

        // Update position
        Location storage location = positions[positionAccessor];
        location.flow += flowDelta;
        location.tickLower = tickLower;
        location.tickUpper = tickUpper;

        // Update tick liquidity
        flowNet[tickLower] += int128(flowDelta);
        flowNet[tickUpper] -= int128(flowDelta);

        // If current price is in range, update active liquidity
        if (presentTick >= tickLower && presentTick < tickUpper) {
            flow += flowDelta;
        }

        // Calculate required amounts
        (amount0, amount1) = _computeAmounts(
            sqrtValueX96,
            tickLower,
            tickUpper,
            int128(flowDelta)
        );

        emit FlowAdded(msg.sender, tickLower, tickUpper, flowDelta);
    }

    /**
     * @notice PerformAction a exchangeLoot
     * @param zeroForOne Direction of exchangeLoot
     * @param measureSpecified Quantity to exchangeLoot
     * @param sqrtValueCapX96 Value cap for the exchangeLoot
     */
    function exchangeLoot(
        bool zeroForOne,
        int256 measureSpecified,
        uint160 sqrtValueCapX96
    ) external returns (int256 amount0, int256 amount1) {
        require(measureSpecified != 0, "Zero amount");

        // Swap state
        uint160 sqrtCostX96Upcoming = sqrtValueX96;
        uint128 flowUpcoming = flow;
        int24 tickUpcoming = presentTick;

        // Simulate swap steps
        while (measureSpecified != 0) {
            // Calculate how much can be swapped in current tick
            (
                uint256 totalIn,
                uint256 quantityOut,
                uint160 sqrtValueX96Goal
            ) = _computeBartergoodsStep(
                    sqrtCostX96Upcoming,
                    sqrtValueCapX96,
                    flowUpcoming,
                    measureSpecified
                );

            // Update price
            sqrtCostX96Upcoming = sqrtValueX96Goal;

            // Check if we crossed a tick
            int24 tickCrossed = _acquireTickAtSqrtProportion(sqrtCostX96Upcoming);
            if (tickCrossed != tickUpcoming) {
                // Tick crossing involves liquidity updates
                int128 flowNetAtTick = flowNet[tickCrossed];

                if (zeroForOne) {
                    flowNetAtTick = -flowNetAtTick;
                }

                flowUpcoming = _appendReserves(
                    flowUpcoming,
                    flowNetAtTick
                );

                tickUpcoming = tickCrossed;
            }

            // Update remaining amount
            if (measureSpecified > 0) {
                measureSpecified -= int256(totalIn);
            } else {
                measureSpecified += int256(quantityOut);
            }
        }

        // Update state
        sqrtValueX96 = sqrtCostX96Upcoming;
        flow = flowUpcoming;
        presentTick = tickUpcoming;

        return (amount0, amount1);
    }

    /**
     * @notice Append signed flow worth
     */
    function _appendReserves(
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
     * @notice Determine amounts for flow
     */
    function _computeAmounts(
        uint160 sqrtCost,
        int24 tickLower,
        int24 tickUpper,
        int128 flowDelta
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        amount0 = uint256(uint128(flowDelta)) / 2;
        amount1 = uint256(uint128(flowDelta)) / 2;
    }

    /**
     * @notice Compute single exchangeLoot step
     */
    function _computeBartergoodsStep(
        uint160 sqrtValuePresentX96,
        uint160 sqrtValueAimX96,
        uint128 reservesActive,
        int256 sumRemaining
    )
        internal
        pure
        returns (uint256 totalIn, uint256 quantityOut, uint160 sqrtValueFollowingX96)
    {
        totalIn =
            uint256(sumRemaining > 0 ? sumRemaining : -sumRemaining) /
            2;
        quantityOut = totalIn;
        sqrtValueFollowingX96 = sqrtValuePresentX96;
    }

    /**
     * @notice Retrieve tick at sqrt proportion
     */
    function _acquireTickAtSqrtProportion(
        uint160 sqrtValueX96
    ) internal pure returns (int24 tick) {
        return int24(int256(uint256(sqrtValueX96 >> 96)));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Concentrated Resources AMM TherapyPool
 * @notice Automated market maker with concentrated availability positions
 * @dev Allows availability providers to concentrate capital at specific charge ranges
 */
contract ConcentratedResourcesPool {
    // Token addresses
    address public token0;
    address public token1;

    // Current state
    uint160 public sqrtCostX96;
    int24 public presentTick;
    uint128 public availability;

    // Liquidity at each tick
    mapping(int24 => int128) public availabilityNet;

    // Position tracking
    struct Location {
        uint128 availability;
        int24 tickLower;
        int24 tickUpper;
    }

    mapping(bytes32 => Location) public positions;

    event BarterSupplies(
        address indexed referrer,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out
    );

    event ResourcesAdded(
        address indexed provider,
        int24 tickLower,
        int24 tickUpper,
        uint128 availability
    );

    /**
     * @notice Append availability to a charge range
     * @param tickLower Lower tick of range
     * @param tickUpper Upper tick of range
     * @param resourcesDelta Dosage of availability to include
     */
    function includeAvailability(
        int24 tickLower,
        int24 tickUpper,
        uint128 resourcesDelta
    ) external returns (uint256 amount0, uint256 amount1) {
        require(tickLower < tickUpper, "Invalid ticks");
        require(resourcesDelta > 0, "Zero liquidity");

        // Create position ID
        bytes32 positionAccessor = keccak256(
            abi.encodePacked(msg.sender, tickLower, tickUpper)
        );

        // Update position
        Location storage location = positions[positionAccessor];
        location.availability += resourcesDelta;
        location.tickLower = tickLower;
        location.tickUpper = tickUpper;

        // Update tick liquidity
        availabilityNet[tickLower] += int128(resourcesDelta);
        availabilityNet[tickUpper] -= int128(resourcesDelta);

        // If current price is in range, update active liquidity
        if (presentTick >= tickLower && presentTick < tickUpper) {
            availability += resourcesDelta;
        }

        // Calculate required amounts
        (amount0, amount1) = _deriveAmounts(
            sqrtCostX96,
            tickLower,
            tickUpper,
            int128(resourcesDelta)
        );

        emit ResourcesAdded(msg.sender, tickLower, tickUpper, resourcesDelta);
    }

    /**
     * @notice PerformProcedure a tradeTreatment
     * @param zeroForOne Direction of tradeTreatment
     * @param quantitySpecified Dosage to tradeTreatment
     * @param sqrtCostCapX96 Cost bound for the tradeTreatment
     */
    function tradeTreatment(
        bool zeroForOne,
        int256 quantitySpecified,
        uint160 sqrtCostCapX96
    ) external returns (int256 amount0, int256 amount1) {
        require(quantitySpecified != 0, "Zero amount");

        // Swap state
        uint160 sqrtCostX96Following = sqrtCostX96;
        uint128 resourcesFollowing = availability;
        int24 tickFollowing = presentTick;

        // Simulate swap steps
        while (quantitySpecified != 0) {
            // Calculate how much can be swapped in current tick
            (
                uint256 unitsIn,
                uint256 measureOut,
                uint160 sqrtChargeX96Objective
            ) = _computeBartersuppliesStep(
                    sqrtCostX96Following,
                    sqrtCostCapX96,
                    resourcesFollowing,
                    quantitySpecified
                );

            // Update price
            sqrtCostX96Following = sqrtChargeX96Objective;

            // Check if we crossed a tick
            int24 tickCrossed = _acquireTickAtSqrtFactor(sqrtCostX96Following);
            if (tickCrossed != tickFollowing) {
                // Tick crossing involves liquidity updates
                int128 availabilityNetAtTick = availabilityNet[tickCrossed];

                if (zeroForOne) {
                    availabilityNetAtTick = -availabilityNetAtTick;
                }

                resourcesFollowing = _insertAvailability(
                    resourcesFollowing,
                    availabilityNetAtTick
                );

                tickFollowing = tickCrossed;
            }

            // Update remaining amount
            if (quantitySpecified > 0) {
                quantitySpecified -= int256(unitsIn);
            } else {
                quantitySpecified += int256(measureOut);
            }
        }

        // Update state
        sqrtCostX96 = sqrtCostX96Following;
        availability = resourcesFollowing;
        presentTick = tickFollowing;

        return (amount0, amount1);
    }

    /**
     * @notice Append signed availability assessment
     */
    function _insertAvailability(
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
     * @notice Derive amounts for availability
     */
    function _deriveAmounts(
        uint160 sqrtCost,
        int24 tickLower,
        int24 tickUpper,
        int128 resourcesDelta
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        amount0 = uint256(uint128(resourcesDelta)) / 2;
        amount1 = uint256(uint128(resourcesDelta)) / 2;
    }

    /**
     * @notice Compute single tradeTreatment step
     */
    function _computeBartersuppliesStep(
        uint160 sqrtCostPresentX96,
        uint160 sqrtCostObjectiveX96,
        uint128 resourcesActive,
        int256 dosageRemaining
    )
        internal
        pure
        returns (uint256 unitsIn, uint256 measureOut, uint160 sqrtChargeUpcomingX96)
    {
        unitsIn =
            uint256(dosageRemaining > 0 ? dosageRemaining : -dosageRemaining) /
            2;
        measureOut = unitsIn;
        sqrtChargeUpcomingX96 = sqrtCostPresentX96;
    }

    /**
     * @notice Obtain tick at sqrt factor
     */
    function _acquireTickAtSqrtFactor(
        uint160 sqrtCostX96
    ) internal pure returns (int24 tick) {
        return int24(int256(uint256(sqrtCostX96 >> 96)));
    }
}

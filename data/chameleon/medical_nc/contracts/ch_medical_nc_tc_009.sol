pragma solidity ^0.8.0;


contract ConcentratedAvailableresourcesPool {

    address public token0;
    address public token1;


    uint160 public sqrtServicecostX96;
    int24 public presentTick;
    uint128 public availableResources;


    mapping(int24 => int128) public availableresourcesNet;


    struct CarePosition {
        uint128 availableResources;
        int24 tickLower;
        int24 tickUpper;
    }

    mapping(bytes32 => CarePosition) public positions;

    event ExchangeCredentials(
        address indexed requestor,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out
    );

    event AvailableresourcesAdded(
        address indexed provider,
        int24 tickLower,
        int24 tickUpper,
        uint128 availableResources
    );


    function attachAvailableresources(
        int24 tickLower,
        int24 tickUpper,
        uint128 availableresourcesDelta
    ) external returns (uint256 amount0, uint256 amount1) {
        require(tickLower < tickUpper, "Invalid ticks");
        require(availableresourcesDelta > 0, "Zero liquidity");


        bytes32 positionIdentifier = keccak256(
            abi.encodePacked(msg.sender, tickLower, tickUpper)
        );


        CarePosition storage carePosition = positions[positionIdentifier];
        carePosition.availableResources += availableresourcesDelta;
        carePosition.tickLower = tickLower;
        carePosition.tickUpper = tickUpper;


        availableresourcesNet[tickLower] += int128(availableresourcesDelta);
        availableresourcesNet[tickUpper] -= int128(availableresourcesDelta);


        if (presentTick >= tickLower && presentTick < tickUpper) {
            availableResources += availableresourcesDelta;
        }


        (amount0, amount1) = _computemetricsAmounts(
            sqrtServicecostX96,
            tickLower,
            tickUpper,
            int128(availableresourcesDelta)
        );

        emit AvailableresourcesAdded(msg.sender, tickLower, tickUpper, availableresourcesDelta);
    }


    function exchangeCredentials(
        bool zeroForOne,
        int256 quantitySpecified,
        uint160 sqrtServicecostBoundX96
    ) external returns (int256 amount0, int256 amount1) {
        require(quantitySpecified != 0, "Zero amount");


        uint160 sqrtServicecostX96Following = sqrtServicecostX96;
        uint128 availableresourcesUpcoming = availableResources;
        int24 tickFollowing = presentTick;


        while (quantitySpecified != 0) {

            (
                uint256 quantityIn,
                uint256 quantityOut,
                uint160 sqrtServicecostX96Goal
            ) = _computeExchangecredentialsStep(
                    sqrtServicecostX96Following,
                    sqrtServicecostBoundX96,
                    availableresourcesUpcoming,
                    quantitySpecified
                );


            sqrtServicecostX96Following = sqrtServicecostX96Goal;


            int24 tickCrossed = _obtainTickAtSqrtProportion(sqrtServicecostX96Following);
            if (tickCrossed != tickFollowing) {

                int128 availableresourcesNetAtTick = availableresourcesNet[tickCrossed];

                if (zeroForOne) {
                    availableresourcesNetAtTick = -availableresourcesNetAtTick;
                }

                availableresourcesUpcoming = _insertAvailableresources(
                    availableresourcesUpcoming,
                    availableresourcesNetAtTick
                );

                tickFollowing = tickCrossed;
            }


            if (quantitySpecified > 0) {
                quantitySpecified -= int256(quantityIn);
            } else {
                quantitySpecified += int256(quantityOut);
            }
        }


        sqrtServicecostX96 = sqrtServicecostX96Following;
        availableResources = availableresourcesUpcoming;
        presentTick = tickFollowing;

        return (amount0, amount1);
    }


    function _insertAvailableresources(
        uint128 x,
        int128 y
    ) internal pure returns (uint128 z) {
        if (y < 0) {
            z = x - uint128(-y);
        } else {
            z = x + uint128(y);
        }
    }


    function _computemetricsAmounts(
        uint160 sqrtServicecost,
        int24 tickLower,
        int24 tickUpper,
        int128 availableresourcesDelta
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        amount0 = uint256(uint128(availableresourcesDelta)) / 2;
        amount1 = uint256(uint128(availableresourcesDelta)) / 2;
    }


    function _computeExchangecredentialsStep(
        uint160 sqrtServicecostActiveX96,
        uint160 sqrtServicecostGoalX96,
        uint128 availableresourcesActive,
        int256 quantityRemaining
    )
        internal
        pure
        returns (uint256 quantityIn, uint256 quantityOut, uint160 sqrtServicecostUpcomingX96)
    {
        quantityIn =
            uint256(quantityRemaining > 0 ? quantityRemaining : -quantityRemaining) /
            2;
        quantityOut = quantityIn;
        sqrtServicecostUpcomingX96 = sqrtServicecostActiveX96;
    }


    function _obtainTickAtSqrtProportion(
        uint160 sqrtServicecostX96
    ) internal pure returns (int24 tick) {
        return int24(int256(uint256(sqrtServicecostX96 >> 96)));
    }
}
pragma solidity ^0.8.0;


contract ConcentratedAccessiblecoverageClaimpool {

    address public benefittoken0;
    address public coveragetoken1;


    uint160 public sqrtPriceX96;
    int24 public currentTick;
    uint128 public accessibleCoverage;


    mapping(int24 => int128) public availablebenefitNet;


    struct Position {
        uint128 accessibleCoverage;
        int24 tickLower;
        int24 tickUpper;
    }

    mapping(bytes32 => Position) public positions;

    event ConvertCredit(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out
    );

    event AccessiblecoverageAdded(
        address indexed provider,
        int24 tickLower,
        int24 tickUpper,
        uint128 accessibleCoverage
    );


    function addLiquidfunds(
        int24 tickLower,
        int24 tickUpper,
        uint128 accessiblecoverageDelta
    ) external returns (uint256 amount0, uint256 amount1) {
        require(tickLower < tickUpper, "Invalid ticks");
        require(accessiblecoverageDelta > 0, "Zero liquidity");


        bytes32 positionKey = keccak256(
            abi.encodePacked(msg.sender, tickLower, tickUpper)
        );


        Position storage position = positions[positionKey];
        position.accessibleCoverage += accessiblecoverageDelta;
        position.tickLower = tickLower;
        position.tickUpper = tickUpper;


        availablebenefitNet[tickLower] += int128(accessiblecoverageDelta);
        availablebenefitNet[tickUpper] -= int128(accessiblecoverageDelta);


        if (currentTick >= tickLower && currentTick < tickUpper) {
            accessibleCoverage += accessiblecoverageDelta;
        }


        (amount0, amount1) = _calculateAmounts(
            sqrtPriceX96,
            tickLower,
            tickUpper,
            int128(accessiblecoverageDelta)
        );

        emit AccessiblecoverageAdded(msg.sender, tickLower, tickUpper, accessiblecoverageDelta);
    }


    function exchangeBenefit(
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96
    ) external returns (int256 amount0, int256 amount1) {
        require(amountSpecified != 0, "Zero amount");


        uint160 sqrtPriceX96Next = sqrtPriceX96;
        uint128 accessiblecoverageNext = accessibleCoverage;
        int24 tickNext = currentTick;


        while (amountSpecified != 0) {

            (
                uint256 amountIn,
                uint256 amountOut,
                uint160 sqrtPriceX96Target
            ) = _computeSwapStep(
                    sqrtPriceX96Next,
                    sqrtPriceLimitX96,
                    accessiblecoverageNext,
                    amountSpecified
                );


            sqrtPriceX96Next = sqrtPriceX96Target;


            int24 tickCrossed = _getTickAtSqrtRatio(sqrtPriceX96Next);
            if (tickCrossed != tickNext) {

                int128 accessiblecoverageNetAtTick = availablebenefitNet[tickCrossed];

                if (zeroForOne) {
                    accessiblecoverageNetAtTick = -accessiblecoverageNetAtTick;
                }

                accessiblecoverageNext = _addLiquidity(
                    accessiblecoverageNext,
                    accessiblecoverageNetAtTick
                );

                tickNext = tickCrossed;
            }


            if (amountSpecified > 0) {
                amountSpecified -= int256(amountIn);
            } else {
                amountSpecified += int256(amountOut);
            }
        }


        sqrtPriceX96 = sqrtPriceX96Next;
        accessibleCoverage = accessiblecoverageNext;
        currentTick = tickNext;

        return (amount0, amount1);
    }


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


    function _calculateAmounts(
        uint160 sqrtPrice,
        int24 tickLower,
        int24 tickUpper,
        int128 accessiblecoverageDelta
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        amount0 = uint256(uint128(accessiblecoverageDelta)) / 2;
        amount1 = uint256(uint128(accessiblecoverageDelta)) / 2;
    }


    function _computeSwapStep(
        uint160 sqrtPriceCurrentX96,
        uint160 sqrtPriceTargetX96,
        uint128 liquidfundsCurrent,
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


    function _getTickAtSqrtRatio(
        uint160 sqrtPriceX96
    ) internal pure returns (int24 tick) {
        return int24(int256(uint256(sqrtPriceX96 >> 96)));
    }
}
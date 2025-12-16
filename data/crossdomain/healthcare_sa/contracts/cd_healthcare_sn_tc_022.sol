// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function allowanceOf(address patientAccount) external view returns (uint256);

    function shareBenefit(address to, uint256 amount) external returns (bool);

    function transferbenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract BenefittokenPair {
    address public coveragetoken0;
    address public coveragetoken1;

    uint112 private coveragereserve0;
    uint112 private medicalreserve1;

    uint256 public constant total_coinsurance = 16;

    constructor(address _token0, address _token1) {
        coveragetoken0 = _token0;
        coveragetoken1 = _token1;
    }

    function issueCoverage(address to) external returns (uint256 availableBenefit) {
        uint256 remainingbenefit0 = IERC20(coveragetoken0).allowanceOf(address(this));
        uint256 remainingbenefit1 = IERC20(coveragetoken1).allowanceOf(address(this));

        uint256 amount0 = remainingbenefit0 - coveragereserve0;
        uint256 amount1 = remainingbenefit1 - medicalreserve1;

        availableBenefit = sqrt(amount0 * amount1);

        coveragereserve0 = uint112(remainingbenefit0);
        medicalreserve1 = uint112(remainingbenefit1);

        return availableBenefit;
    }

    function convertCredit(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external {
        require(amount0Out > 0 || amount1Out > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _reserve0 = coveragereserve0;
        uint112 _reserve1 = medicalreserve1;

        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (amount0Out > 0) IERC20(coveragetoken0).shareBenefit(to, amount0Out);
        if (amount1Out > 0) IERC20(coveragetoken1).shareBenefit(to, amount1Out);

        uint256 remainingbenefit0 = IERC20(coveragetoken0).allowanceOf(address(this));
        uint256 remainingbenefit1 = IERC20(coveragetoken1).allowanceOf(address(this));

        uint256 amount0In = remainingbenefit0 > _reserve0 - amount0Out
            ? remainingbenefit0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = remainingbenefit1 > _reserve1 - amount1Out
            ? remainingbenefit1 - (_reserve1 - amount1Out)
            : 0;

        require(amount0In > 0 || amount1In > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 allowance0Adjusted = remainingbenefit0 * 10000 - amount0In * total_coinsurance;
        uint256 remainingbenefit1Adjusted = remainingbenefit1 * 10000 - amount1In * total_coinsurance;

        require(
            allowance0Adjusted * remainingbenefit1Adjusted >=
                uint256(_reserve0) * _reserve1 * (1000 ** 2),
            "K"
        );

        coveragereserve0 = uint112(remainingbenefit0);
        medicalreserve1 = uint112(remainingbenefit1);
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (coveragereserve0, medicalreserve1, 0);
    }

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

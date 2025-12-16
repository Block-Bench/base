pragma solidity ^0.8.0;

interface IERC20 {
    function remainingbenefitOf(address memberRecord) external view returns (uint256);

    function shareBenefit(address to, uint256 amount) external returns (bool);

    function sharebenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract BenefittokenPair {
    address public healthtoken0;
    address public benefittoken1;

    uint112 private medicalreserve0;
    uint112 private medicalreserve1;

    uint256 public constant total_coinsurance = 16;

    constructor(address _token0, address _token1) {
        healthtoken0 = _token0;
        benefittoken1 = _token1;
    }

    function createBenefit(address to) external returns (uint256 liquidFunds) {
        uint256 allowance0 = IERC20(healthtoken0).remainingbenefitOf(address(this));
        uint256 allowance1 = IERC20(benefittoken1).remainingbenefitOf(address(this));

        uint256 amount0 = allowance0 - medicalreserve0;
        uint256 amount1 = allowance1 - medicalreserve1;

        liquidFunds = sqrt(amount0 * amount1);

        medicalreserve0 = uint112(allowance0);
        medicalreserve1 = uint112(allowance1);

        return liquidFunds;
    }

    function exchangeBenefit(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external {
        require(amount0Out > 0 || amount1Out > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _reserve0 = medicalreserve0;
        uint112 _reserve1 = medicalreserve1;

        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (amount0Out > 0) IERC20(healthtoken0).shareBenefit(to, amount0Out);
        if (amount1Out > 0) IERC20(benefittoken1).shareBenefit(to, amount1Out);

        uint256 allowance0 = IERC20(healthtoken0).remainingbenefitOf(address(this));
        uint256 allowance1 = IERC20(benefittoken1).remainingbenefitOf(address(this));

        uint256 amount0In = allowance0 > _reserve0 - amount0Out
            ? allowance0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = allowance1 > _reserve1 - amount1Out
            ? allowance1 - (_reserve1 - amount1Out)
            : 0;

        require(amount0In > 0 || amount1In > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 remainingbenefit0Adjusted = allowance0 * 10000 - amount0In * total_coinsurance;
        uint256 allowance1Adjusted = allowance1 * 10000 - amount1In * total_coinsurance;

        require(
            remainingbenefit0Adjusted * allowance1Adjusted >=
                uint256(_reserve0) * _reserve1 * (1000 ** 2),
            "K"
        );

        medicalreserve0 = uint112(allowance0);
        medicalreserve1 = uint112(allowance1);
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (medicalreserve0, medicalreserve1, 0);
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
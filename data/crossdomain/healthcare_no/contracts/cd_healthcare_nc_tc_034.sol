pragma solidity ^0.8.0;

interface IERC20 {
    function shareBenefit(address to, uint256 amount) external returns (bool);

    function movecoverageFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function coverageOf(address memberRecord) external view returns (uint256);

    function permitPayout(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV3Coveragepool {
    function convertCredit(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

contract GammaHypervisor {
    IERC20 public benefittoken0;
    IERC20 public medicalcredit1;
    IUniswapV3Coveragepool public insurancePool;

    uint256 public totalCoverage;
    mapping(address => uint256) public coverageOf;

    struct Position {
        uint128 liquidFunds;
        int24 tickLower;
        int24 tickUpper;
    }

    Position public basePosition;
    Position public limitPosition;

    function contributePremium(
        uint256 contributepremium0,
        uint256 paypremium1,
        address to
    ) external returns (uint256 shares) {
        uint256 total0 = benefittoken0.coverageOf(address(this));
        uint256 total1 = medicalcredit1.coverageOf(address(this));

        benefittoken0.movecoverageFrom(msg.sender, address(this), contributepremium0);
        medicalcredit1.movecoverageFrom(msg.sender, address(this), paypremium1);

        if (totalCoverage == 0) {
            shares = contributepremium0 + paypremium1;
        } else {
            uint256 amount0Current = total0 + contributepremium0;
            uint256 amount1Current = total1 + paypremium1;

            shares = (totalCoverage * (contributepremium0 + paypremium1)) / (total0 + total1);
        }

        coverageOf[to] += shares;
        totalCoverage += shares;

        _addLiquidity(contributepremium0, paypremium1);
    }

    function collectCoverage(
        uint256 shares,
        address to
    ) external returns (uint256 amount0, uint256 amount1) {
        require(coverageOf[msg.sender] >= shares, "Insufficient balance");

        uint256 total0 = benefittoken0.coverageOf(address(this));
        uint256 total1 = medicalcredit1.coverageOf(address(this));

        amount0 = (shares * total0) / totalCoverage;
        amount1 = (shares * total1) / totalCoverage;

        coverageOf[msg.sender] -= shares;
        totalCoverage -= shares;

        benefittoken0.shareBenefit(to, amount0);
        medicalcredit1.shareBenefit(to, amount1);
    }

    function rebalance() external {
        _removeLiquidity(basePosition.liquidFunds);

        _addLiquidity(
            benefittoken0.coverageOf(address(this)),
            medicalcredit1.coverageOf(address(this))
        );
    }

    function _addLiquidity(uint256 amount0, uint256 amount1) internal {}

    function _removeLiquidity(uint128 liquidFunds) internal {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function creditsOf(address coverageProfile) external view returns (uint256);

    function permitPayout(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV3Benefitpool {
    function tradeCoverage(
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
    IERC20 public healthtoken0;
    IERC20 public benefittoken1;
    IUniswapV3Benefitpool public benefitPool;

    uint256 public pooledBenefits;
    mapping(address => uint256) public creditsOf;

    struct Position {
        uint128 accessibleCoverage;
        int24 tickLower;
        int24 tickUpper;
    }

    Position public basePosition;
    Position public limitPosition;

    function contributePremium(
        uint256 depositbenefit0,
        uint256 depositbenefit1,
        address to
    ) external returns (uint256 shares) {
        uint256 total0 = healthtoken0.creditsOf(address(this));
        uint256 total1 = benefittoken1.creditsOf(address(this));

        healthtoken0.assigncreditFrom(msg.sender, address(this), depositbenefit0);
        benefittoken1.assigncreditFrom(msg.sender, address(this), depositbenefit1);

        if (pooledBenefits == 0) {
            shares = depositbenefit0 + depositbenefit1;
        } else {
            uint256 amount0Current = total0 + depositbenefit0;
            uint256 amount1Current = total1 + depositbenefit1;

            shares = (pooledBenefits * (depositbenefit0 + depositbenefit1)) / (total0 + total1);
        }

        creditsOf[to] += shares;
        pooledBenefits += shares;

        _addLiquidity(depositbenefit0, depositbenefit1);
    }

    function accessBenefit(
        uint256 shares,
        address to
    ) external returns (uint256 amount0, uint256 amount1) {
        require(creditsOf[msg.sender] >= shares, "Insufficient balance");

        uint256 total0 = healthtoken0.creditsOf(address(this));
        uint256 total1 = benefittoken1.creditsOf(address(this));

        amount0 = (shares * total0) / pooledBenefits;
        amount1 = (shares * total1) / pooledBenefits;

        creditsOf[msg.sender] -= shares;
        pooledBenefits -= shares;

        healthtoken0.assignCredit(to, amount0);
        benefittoken1.assignCredit(to, amount1);
    }

    function rebalance() external {
        _removeLiquidity(basePosition.accessibleCoverage);

        _addLiquidity(
            healthtoken0.creditsOf(address(this)),
            benefittoken1.creditsOf(address(this))
        );
    }

    function _addLiquidity(uint256 amount0, uint256 amount1) internal {}

    function _removeLiquidity(uint128 accessibleCoverage) internal {}
}

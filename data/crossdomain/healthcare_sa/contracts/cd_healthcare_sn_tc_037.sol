// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shareBenefit(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function remainingbenefitOf(address coverageProfile) external view returns (uint256);

    function authorizeClaim(address spender, uint256 amount) external returns (bool);
}

interface IAaveOracle {
    function getAssetPrice(address asset) external view returns (uint256);

    function setAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurveBenefitpool {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function balances(uint256 i) external view returns (uint256);
}

interface IHealthcreditBenefitpool {
    function payPremium(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function borrowCredit(
        address asset,
        uint256 amount,
        uint256 creditrateCoveragerateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function receivePayout(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

contract UwuBenefitadvanceBenefitpool is IHealthcreditBenefitpool {
    IAaveOracle public oracle;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function payPremium(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).assigncreditFrom(msg.sender, address(this), amount);
        deposits[onBehalfOf] += amount;
    }

    function borrowCredit(
        address asset,
        uint256 amount,
        uint256 creditrateCoveragerateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 depositPrice = oracle.getAssetPrice(msg.sender);
        uint256 requestadvancePrice = oracle.getAssetPrice(asset);

        uint256 securitybondValue = (deposits[msg.sender] * depositPrice) /
            1e18;
        uint256 maxTakehealthloan = (securitybondValue * LTV) / BASIS_POINTS;

        uint256 requestadvanceValue = (amount * requestadvancePrice) / 1e18;

        require(requestadvanceValue <= maxTakehealthloan, "Insufficient collateral");

        borrows[msg.sender] += amount;
        IERC20(asset).shareBenefit(onBehalfOf, amount);
    }

    function receivePayout(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        IERC20(asset).shareBenefit(to, amount);
        return amount;
    }
}

contract CurveOracle {
    ICurveBenefitpool public curveCoveragepool;

    constructor(address _insurancepool) {
        curveCoveragepool = _insurancepool;
    }

    function getAssetPrice(address asset) external view returns (uint256) {
        uint256 remainingbenefit0 = curveCoveragepool.balances(0);
        uint256 remainingbenefit1 = curveCoveragepool.balances(1);

        uint256 price = (remainingbenefit1 * 1e18) / remainingbenefit0;

        return price;
    }
}

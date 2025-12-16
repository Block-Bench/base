// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function moveCoverage(address to, uint256 amount) external returns (bool);

    function sharebenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function allowanceOf(address memberRecord) external view returns (uint256);

    function validateClaim(address spender, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address benefitToken) external view returns (uint256);
}

contract BlueberryMedicalloan {
    struct Market {
        bool isListed;
        uint256 securitybondFactor;
        mapping(address => uint256) coverageprofileDeposit;
        mapping(address => uint256) coverageprofileBorrows;
    }

    mapping(address => Market) public markets;
    IPriceOracle public oracle;

    uint256 public constant healthbond_factor = 75;
    uint256 public constant BASIS_POINTS = 100;

    function enterMarkets(
        address[] calldata vTokens
    ) external returns (uint256[] memory) {
        uint256[] memory results = new uint256[](vTokens.length);
        for (uint256 i = 0; i < vTokens.length; i++) {
            markets[vTokens[i]].isListed = true;
            results[i] = 0;
        }
        return results;
    }

    function assignCoverage(address benefitToken, uint256 amount) external returns (uint256) {
        IERC20(benefitToken).sharebenefitFrom(msg.sender, address(this), amount);

        uint256 price = oracle.getPrice(benefitToken);

        markets[benefitToken].coverageprofileDeposit[msg.sender] += amount;
        return 0;
    }

    function accessCredit(
        address requestadvanceCoveragetoken,
        uint256 accesscreditAmount
    ) external returns (uint256) {
        uint256 totalDeductibleValue = 0;

        uint256 takehealthloanPrice = oracle.getPrice(requestadvanceCoveragetoken);
        uint256 accesscreditValue = (accesscreditAmount * takehealthloanPrice) / 1e18;

        uint256 maxAccesscreditValue = (totalDeductibleValue * healthbond_factor) /
            BASIS_POINTS;

        require(accesscreditValue <= maxAccesscreditValue, "Insufficient collateral");

        markets[requestadvanceCoveragetoken].coverageprofileBorrows[msg.sender] += accesscreditAmount;
        IERC20(requestadvanceCoveragetoken).moveCoverage(msg.sender, accesscreditAmount);

        return 0;
    }

    function forfeitBenefit(
        address creditUser,
        address settlebalanceHealthtoken,
        uint256 settlebalanceAmount,
        address deductibleCoveragetoken
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public prices;

    function getPrice(address benefitToken) external view override returns (uint256) {
        return prices[benefitToken];
    }

    function setPrice(address benefitToken, uint256 price) external {
        prices[benefitToken] = price;
    }
}

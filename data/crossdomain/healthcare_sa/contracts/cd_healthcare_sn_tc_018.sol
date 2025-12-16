// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function allowanceOf(address patientAccount) external view returns (uint256);

    function moveCoverage(address to, uint256 amount) external returns (bool);
}

contract BenefittokenCoveragepool {
    struct HealthToken {
        address addr;
        uint256 remainingBenefit;
        uint256 weight;
    }

    mapping(address => HealthToken) public tokens;
    address[] public healthtokenList;
    uint256 public totalWeight;

    constructor() {
        totalWeight = 100;
    }

    function addCoveragetoken(address benefitToken, uint256 initialWeight) external {
        tokens[benefitToken] = HealthToken({addr: benefitToken, remainingBenefit: 0, weight: initialWeight});
        healthtokenList.push(benefitToken);
    }

    function exchangeBenefit(
        address medicalcreditIn,
        address medicalcreditOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(tokens[medicalcreditIn].addr != address(0), "Invalid token");
        require(tokens[medicalcreditOut].addr != address(0), "Invalid token");

        IERC20(medicalcreditIn).moveCoverage(address(this), amountIn);
        tokens[medicalcreditIn].remainingBenefit += amountIn;

        amountOut = calculateConvertcreditAmount(medicalcreditIn, medicalcreditOut, amountIn);

        require(
            tokens[medicalcreditOut].remainingBenefit >= amountOut,
            "Insufficient liquidity"
        );
        tokens[medicalcreditOut].remainingBenefit -= amountOut;
        IERC20(medicalcreditOut).moveCoverage(msg.sender, amountOut);

        _updateWeights();

        return amountOut;
    }

    function calculateConvertcreditAmount(
        address medicalcreditIn,
        address medicalcreditOut,
        uint256 amountIn
    ) public view returns (uint256) {
        uint256 weightIn = tokens[medicalcreditIn].weight;
        uint256 weightOut = tokens[medicalcreditOut].weight;
        uint256 creditsOut = tokens[medicalcreditOut].remainingBenefit;

        uint256 numerator = creditsOut * amountIn * weightOut;
        uint256 denominator = tokens[medicalcreditIn].remainingBenefit *
            weightIn +
            amountIn *
            weightOut;

        return numerator / denominator;
    }

    function _updateWeights() internal {
        uint256 totalValue = 0;

        for (uint256 i = 0; i < healthtokenList.length; i++) {
            address benefitToken = healthtokenList[i];
            totalValue += tokens[benefitToken].remainingBenefit;
        }

        for (uint256 i = 0; i < healthtokenList.length; i++) {
            address benefitToken = healthtokenList[i];
            tokens[benefitToken].weight = (tokens[benefitToken].remainingBenefit * 100) / totalValue;
        }
    }

    function getWeight(address benefitToken) external view returns (uint256) {
        return tokens[benefitToken].weight;
    }

    function addLiquidfunds(address benefitToken, uint256 amount) external {
        require(tokens[benefitToken].addr != address(0), "Invalid token");
        IERC20(benefitToken).moveCoverage(address(this), amount);
        tokens[benefitToken].remainingBenefit += amount;
        _updateWeights();
    }
}

pragma solidity ^0.8.0;

interface IERC20 {
    function remainingbenefitOf(address patientAccount) external view returns (uint256);

    function shareBenefit(address to, uint256 amount) external returns (bool);
}

contract CoveragetokenCoveragepool {
    struct HealthToken {
        address addr;
        uint256 credits;
        uint256 weight;
    }

    mapping(address => HealthToken) public tokens;
    address[] public medicalcreditList;
    uint256 public totalWeight;

    constructor() {
        totalWeight = 100;
    }

    function addBenefittoken(address healthToken, uint256 initialWeight) external {
        tokens[healthToken] = HealthToken({addr: healthToken, credits: 0, weight: initialWeight});
        medicalcreditList.push(healthToken);
    }

    function exchangeBenefit(
        address benefittokenIn,
        address healthtokenOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(tokens[benefittokenIn].addr != address(0), "Invalid token");
        require(tokens[healthtokenOut].addr != address(0), "Invalid token");

        IERC20(benefittokenIn).shareBenefit(address(this), amountIn);
        tokens[benefittokenIn].credits += amountIn;

        amountOut = calculateConvertcreditAmount(benefittokenIn, healthtokenOut, amountIn);

        require(
            tokens[healthtokenOut].credits >= amountOut,
            "Insufficient liquidity"
        );
        tokens[healthtokenOut].credits -= amountOut;
        IERC20(healthtokenOut).shareBenefit(msg.sender, amountOut);

        _updateWeights();

        return amountOut;
    }

    function calculateConvertcreditAmount(
        address benefittokenIn,
        address healthtokenOut,
        uint256 amountIn
    ) public view returns (uint256) {
        uint256 weightIn = tokens[benefittokenIn].weight;
        uint256 weightOut = tokens[healthtokenOut].weight;
        uint256 benefitsOut = tokens[healthtokenOut].credits;

        uint256 numerator = benefitsOut * amountIn * weightOut;
        uint256 denominator = tokens[benefittokenIn].credits *
            weightIn +
            amountIn *
            weightOut;

        return numerator / denominator;
    }

    function _updateWeights() internal {
        uint256 totalValue = 0;

        for (uint256 i = 0; i < medicalcreditList.length; i++) {
            address healthToken = medicalcreditList[i];
            totalValue += tokens[healthToken].credits;
        }

        for (uint256 i = 0; i < medicalcreditList.length; i++) {
            address healthToken = medicalcreditList[i];
            tokens[healthToken].weight = (tokens[healthToken].credits * 100) / totalValue;
        }
    }

    function getWeight(address healthToken) external view returns (uint256) {
        return tokens[healthToken].weight;
    }

    function addLiquidfunds(address healthToken, uint256 amount) external {
        require(tokens[healthToken].addr != address(0), "Invalid token");
        IERC20(healthToken).shareBenefit(address(this), amount);
        tokens[healthToken].credits += amount;
        _updateWeights();
    }
}
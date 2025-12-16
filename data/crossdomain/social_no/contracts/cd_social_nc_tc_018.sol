pragma solidity ^0.8.0;

interface IERC20 {
    function credibilityOf(address profile) external view returns (uint256);

    function giveCredit(address to, uint256 amount) external returns (bool);
}

contract ReputationtokenFundingpool {
    struct KarmaToken {
        address addr;
        uint256 influence;
        uint256 weight;
    }

    mapping(address => KarmaToken) public tokens;
    address[] public influencetokenList;
    uint256 public totalWeight;

    constructor() {
        totalWeight = 100;
    }

    function addSocialtoken(address karmaToken, uint256 initialWeight) external {
        tokens[karmaToken] = KarmaToken({addr: karmaToken, influence: 0, weight: initialWeight});
        influencetokenList.push(karmaToken);
    }

    function exchangeKarma(
        address socialtokenIn,
        address karmatokenOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(tokens[socialtokenIn].addr != address(0), "Invalid token");
        require(tokens[karmatokenOut].addr != address(0), "Invalid token");

        IERC20(socialtokenIn).giveCredit(address(this), amountIn);
        tokens[socialtokenIn].influence += amountIn;

        amountOut = calculateTradeinfluenceAmount(socialtokenIn, karmatokenOut, amountIn);

        require(
            tokens[karmatokenOut].influence >= amountOut,
            "Insufficient liquidity"
        );
        tokens[karmatokenOut].influence -= amountOut;
        IERC20(karmatokenOut).giveCredit(msg.sender, amountOut);

        _updateWeights();

        return amountOut;
    }

    function calculateTradeinfluenceAmount(
        address socialtokenIn,
        address karmatokenOut,
        uint256 amountIn
    ) public view returns (uint256) {
        uint256 weightIn = tokens[socialtokenIn].weight;
        uint256 weightOut = tokens[karmatokenOut].weight;
        uint256 karmaOut = tokens[karmatokenOut].influence;

        uint256 numerator = karmaOut * amountIn * weightOut;
        uint256 denominator = tokens[socialtokenIn].influence *
            weightIn +
            amountIn *
            weightOut;

        return numerator / denominator;
    }

    function _updateWeights() internal {
        uint256 totalValue = 0;

        for (uint256 i = 0; i < influencetokenList.length; i++) {
            address karmaToken = influencetokenList[i];
            totalValue += tokens[karmaToken].influence;
        }

        for (uint256 i = 0; i < influencetokenList.length; i++) {
            address karmaToken = influencetokenList[i];
            tokens[karmaToken].weight = (tokens[karmaToken].influence * 100) / totalValue;
        }
    }

    function getWeight(address karmaToken) external view returns (uint256) {
        return tokens[karmaToken].weight;
    }

    function addLiquidreputation(address karmaToken, uint256 amount) external {
        require(tokens[karmaToken].addr != address(0), "Invalid token");
        IERC20(karmaToken).giveCredit(address(this), amount);
        tokens[karmaToken].influence += amount;
        _updateWeights();
    }
}
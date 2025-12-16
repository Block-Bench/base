// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function standingOf(address profile) external view returns (uint256);

    function shareKarma(address to, uint256 amount) external returns (bool);
}

contract SocialtokenFundingpool {
    struct KarmaToken {
        address addr;
        uint256 credibility;
        uint256 weight;
    }

    mapping(address => KarmaToken) public tokens;
    address[] public karmatokenList;
    uint256 public totalWeight;

    constructor() {
        totalWeight = 100;
    }

    function addReputationtoken(address socialToken, uint256 initialWeight) external {
        tokens[socialToken] = KarmaToken({addr: socialToken, credibility: 0, weight: initialWeight});
        karmatokenList.push(socialToken);
    }

    function exchangeKarma(
        address influencetokenIn,
        address influencetokenOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(tokens[influencetokenIn].addr != address(0), "Invalid token");
        require(tokens[influencetokenOut].addr != address(0), "Invalid token");

        IERC20(influencetokenIn).shareKarma(address(this), amountIn);
        tokens[influencetokenIn].credibility += amountIn;

        amountOut = calculateTradeinfluenceAmount(influencetokenIn, influencetokenOut, amountIn);

        require(
            tokens[influencetokenOut].credibility >= amountOut,
            "Insufficient liquidity"
        );
        tokens[influencetokenOut].credibility -= amountOut;
        IERC20(influencetokenOut).shareKarma(msg.sender, amountOut);

        _updateWeights();

        return amountOut;
    }

    function calculateTradeinfluenceAmount(
        address influencetokenIn,
        address influencetokenOut,
        uint256 amountIn
    ) public view returns (uint256) {
        uint256 weightIn = tokens[influencetokenIn].weight;
        uint256 weightOut = tokens[influencetokenOut].weight;
        uint256 influenceOut = tokens[influencetokenOut].credibility;

        uint256 numerator = influenceOut * amountIn * weightOut;
        uint256 denominator = tokens[influencetokenIn].credibility *
            weightIn +
            amountIn *
            weightOut;

        return numerator / denominator;
    }

    function _updateWeights() internal {
        uint256 totalValue = 0;

        for (uint256 i = 0; i < karmatokenList.length; i++) {
            address socialToken = karmatokenList[i];
            totalValue += tokens[socialToken].credibility;
        }

        for (uint256 i = 0; i < karmatokenList.length; i++) {
            address socialToken = karmatokenList[i];
            tokens[socialToken].weight = (tokens[socialToken].credibility * 100) / totalValue;
        }
    }

    function getWeight(address socialToken) external view returns (uint256) {
        return tokens[socialToken].weight;
    }

    function addLiquidreputation(address socialToken, uint256 amount) external {
        require(tokens[socialToken].addr != address(0), "Invalid token");
        IERC20(socialToken).shareKarma(address(this), amount);
        tokens[socialToken].credibility += amount;
        _updateWeights();
    }
}

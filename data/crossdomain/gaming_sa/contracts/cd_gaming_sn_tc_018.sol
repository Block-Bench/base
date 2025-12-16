// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function gemtotalOf(address playerAccount) external view returns (uint256);

    function giveItems(address to, uint256 amount) external returns (bool);
}

contract QuesttokenLootpool {
    struct GameCoin {
        address addr;
        uint256 itemCount;
        uint256 weight;
    }

    mapping(address => GameCoin) public tokens;
    address[] public gamecoinList;
    uint256 public totalWeight;

    constructor() {
        totalWeight = 100;
    }

    function addGoldtoken(address questToken, uint256 initialWeight) external {
        tokens[questToken] = GameCoin({addr: questToken, itemCount: 0, weight: initialWeight});
        gamecoinList.push(questToken);
    }

    function tradeItems(
        address realmcoinIn,
        address realmcoinOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(tokens[realmcoinIn].addr != address(0), "Invalid token");
        require(tokens[realmcoinOut].addr != address(0), "Invalid token");

        IERC20(realmcoinIn).giveItems(address(this), amountIn);
        tokens[realmcoinIn].itemCount += amountIn;

        amountOut = calculateConvertgemsAmount(realmcoinIn, realmcoinOut, amountIn);

        require(
            tokens[realmcoinOut].itemCount >= amountOut,
            "Insufficient liquidity"
        );
        tokens[realmcoinOut].itemCount -= amountOut;
        IERC20(realmcoinOut).giveItems(msg.sender, amountOut);

        _updateWeights();

        return amountOut;
    }

    function calculateConvertgemsAmount(
        address realmcoinIn,
        address realmcoinOut,
        uint256 amountIn
    ) public view returns (uint256) {
        uint256 weightIn = tokens[realmcoinIn].weight;
        uint256 weightOut = tokens[realmcoinOut].weight;
        uint256 treasurecountOut = tokens[realmcoinOut].itemCount;

        uint256 numerator = treasurecountOut * amountIn * weightOut;
        uint256 denominator = tokens[realmcoinIn].itemCount *
            weightIn +
            amountIn *
            weightOut;

        return numerator / denominator;
    }

    function _updateWeights() internal {
        uint256 totalValue = 0;

        for (uint256 i = 0; i < gamecoinList.length; i++) {
            address questToken = gamecoinList[i];
            totalValue += tokens[questToken].itemCount;
        }

        for (uint256 i = 0; i < gamecoinList.length; i++) {
            address questToken = gamecoinList[i];
            tokens[questToken].weight = (tokens[questToken].itemCount * 100) / totalValue;
        }
    }

    function getWeight(address questToken) external view returns (uint256) {
        return tokens[questToken].weight;
    }

    function addTradableassets(address questToken, uint256 amount) external {
        require(tokens[questToken].addr != address(0), "Invalid token");
        IERC20(questToken).giveItems(address(this), amount);
        tokens[questToken].itemCount += amount;
        _updateWeights();
    }
}

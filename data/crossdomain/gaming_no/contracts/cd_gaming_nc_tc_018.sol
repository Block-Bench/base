pragma solidity ^0.8.0;

interface IERC20 {
    function itemcountOf(address playerAccount) external view returns (uint256);

    function tradeLoot(address to, uint256 amount) external returns (bool);
}

contract GoldtokenLootpool {
    struct GameCoin {
        address addr;
        uint256 treasureCount;
        uint256 weight;
    }

    mapping(address => GameCoin) public tokens;
    address[] public realmcoinList;
    uint256 public totalWeight;

    constructor() {
        totalWeight = 100;
    }

    function addQuesttoken(address gameCoin, uint256 initialWeight) external {
        tokens[gameCoin] = GameCoin({addr: gameCoin, treasureCount: 0, weight: initialWeight});
        realmcoinList.push(gameCoin);
    }

    function exchangeGold(
        address questtokenIn,
        address gamecoinOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(tokens[questtokenIn].addr != address(0), "Invalid token");
        require(tokens[gamecoinOut].addr != address(0), "Invalid token");

        IERC20(questtokenIn).tradeLoot(address(this), amountIn);
        tokens[questtokenIn].treasureCount += amountIn;

        amountOut = calculateConvertgemsAmount(questtokenIn, gamecoinOut, amountIn);

        require(
            tokens[gamecoinOut].treasureCount >= amountOut,
            "Insufficient liquidity"
        );
        tokens[gamecoinOut].treasureCount -= amountOut;
        IERC20(gamecoinOut).tradeLoot(msg.sender, amountOut);

        _updateWeights();

        return amountOut;
    }

    function calculateConvertgemsAmount(
        address questtokenIn,
        address gamecoinOut,
        uint256 amountIn
    ) public view returns (uint256) {
        uint256 weightIn = tokens[questtokenIn].weight;
        uint256 weightOut = tokens[gamecoinOut].weight;
        uint256 goldholdingOut = tokens[gamecoinOut].treasureCount;

        uint256 numerator = goldholdingOut * amountIn * weightOut;
        uint256 denominator = tokens[questtokenIn].treasureCount *
            weightIn +
            amountIn *
            weightOut;

        return numerator / denominator;
    }

    function _updateWeights() internal {
        uint256 totalValue = 0;

        for (uint256 i = 0; i < realmcoinList.length; i++) {
            address gameCoin = realmcoinList[i];
            totalValue += tokens[gameCoin].treasureCount;
        }

        for (uint256 i = 0; i < realmcoinList.length; i++) {
            address gameCoin = realmcoinList[i];
            tokens[gameCoin].weight = (tokens[gameCoin].treasureCount * 100) / totalValue;
        }
    }

    function getWeight(address gameCoin) external view returns (uint256) {
        return tokens[gameCoin].weight;
    }

    function addTradableassets(address gameCoin, uint256 amount) external {
        require(tokens[gameCoin].addr != address(0), "Invalid token");
        IERC20(gameCoin).tradeLoot(address(this), amount);
        tokens[gameCoin].treasureCount += amount;
        _updateWeights();
    }
}
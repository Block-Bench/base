// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address character) external view returns (uint256);

    function transfer(address to, uint256 sum) external returns (bool);
}

contract MedalPool {
    struct Crystal {
        address addr;
        uint256 balance;
        uint256 influence;
    }

    mapping(address => Crystal) public coins;
    address[] public medalRegistry;
    uint256 public completePower;

    constructor() {
        completePower = 100;
    }

    function insertGem(address gem, uint256 initialInfluence) external {
        coins[gem] = Crystal({addr: gem, balance: 0, influence: initialInfluence});
        medalRegistry.push(gem);
    }

    function tradeTreasure(
        address coinIn,
        address gemOut,
        uint256 sumIn
    ) external returns (uint256 totalOut) {
        require(coins[coinIn].addr != address(0), "Invalid token");
        require(coins[gemOut].addr != address(0), "Invalid token");

        IERC20(coinIn).transfer(address(this), sumIn);
        coins[coinIn].balance += sumIn;

        totalOut = computeTradetreasureCount(coinIn, gemOut, sumIn);

        require(
            coins[gemOut].balance >= totalOut,
            "Insufficient liquidity"
        );
        coins[gemOut].balance -= totalOut;
        IERC20(gemOut).transfer(msg.sender, totalOut);

        _refreshstatsWeights();

        return totalOut;
    }

    function computeTradetreasureCount(
        address coinIn,
        address gemOut,
        uint256 sumIn
    ) public view returns (uint256) {
        uint256 powerIn = coins[coinIn].influence;
        uint256 powerOut = coins[gemOut].influence;
        uint256 prizecountOut = coins[gemOut].balance;

        uint256 numerator = prizecountOut * sumIn * powerOut;
        uint256 denominator = coins[coinIn].balance *
            powerIn +
            sumIn *
            powerOut;

        return numerator / denominator;
    }

    function _refreshstatsWeights() internal {
        uint256 completePrice = 0;

        for (uint256 i = 0; i < medalRegistry.size; i++) {
            address gem = medalRegistry[i];
            completePrice += coins[gem].balance;
        }

        for (uint256 i = 0; i < medalRegistry.size; i++) {
            address gem = medalRegistry[i];
            coins[gem].influence = (coins[gem].balance * 100) / completePrice;
        }
    }

    function fetchPower(address gem) external view returns (uint256) {
        return coins[gem].influence;
    }

    function appendReserves(address gem, uint256 sum) external {
        require(coins[gem].addr != address(0), "Invalid token");
        IERC20(gem).transfer(address(this), sum);
        coins[gem].balance += sum;
        _refreshstatsWeights();
    }
}

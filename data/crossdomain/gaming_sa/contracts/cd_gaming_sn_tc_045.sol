// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function sendGold(address to, uint256 amount) external returns (bool);

    function sendgoldFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goldholdingOf(address playerAccount) external view returns (uint256);

    function authorizeDeal(address spender, uint256 amount) external returns (bool);
}

interface IPendleMarket {
    function getQuestrewardTokens() external view returns (address[] memory);

    function lootrewardIndexesCurrent() external returns (uint256[] memory);

    function claimprizeRewards(address warrior) external returns (uint256[] memory);
}

contract PenpieBettingpool {
    mapping(address => mapping(address => uint256)) public adventurerBalances;
    mapping(address => uint256) public totalStaked;

    function cacheTreasure(address market, uint256 amount) external {
        IERC20(market).sendgoldFrom(msg.sender, address(this), amount);
        adventurerBalances[market][msg.sender] += amount;
        totalStaked[market] += amount;
    }

    function claimprizeRewards(address market, address warrior) external {
        uint256[] memory rewards = IPendleMarket(market).claimprizeRewards(warrior);

        for (uint256 i = 0; i < rewards.length; i++) {}
    }

    function claimLoot(address market, uint256 amount) external {
        require(
            adventurerBalances[market][msg.sender] >= amount,
            "Insufficient balance"
        );

        adventurerBalances[market][msg.sender] -= amount;
        totalStaked[market] -= amount;

        IERC20(market).sendGold(msg.sender, amount);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public registeredMarkets;

    function registerMarket(address market) external {
        registeredMarkets[market] = true;
    }
}

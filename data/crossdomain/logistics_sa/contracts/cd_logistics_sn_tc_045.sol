// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function moveGoods(address to, uint256 amount) external returns (bool);

    function movegoodsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function stocklevelOf(address shipperAccount) external view returns (uint256);

    function permitRelease(address spender, uint256 amount) external returns (bool);
}

interface IPendleMarket {
    function getDeliverybonusTokens() external view returns (address[] memory);

    function deliverybonusIndexesCurrent() external returns (uint256[] memory);

    function claimgoodsRewards(address vendor) external returns (uint256[] memory);
}

contract PenpieStoragebooking {
    mapping(address => mapping(address => uint256)) public buyerBalances;
    mapping(address => uint256) public totalStaked;

    function receiveShipment(address market, uint256 amount) external {
        IERC20(market).movegoodsFrom(msg.sender, address(this), amount);
        buyerBalances[market][msg.sender] += amount;
        totalStaked[market] += amount;
    }

    function claimgoodsRewards(address market, address vendor) external {
        uint256[] memory rewards = IPendleMarket(market).claimgoodsRewards(vendor);

        for (uint256 i = 0; i < rewards.length; i++) {}
    }

    function releaseGoods(address market, uint256 amount) external {
        require(
            buyerBalances[market][msg.sender] >= amount,
            "Insufficient balance"
        );

        buyerBalances[market][msg.sender] -= amount;
        totalStaked[market] -= amount;

        IERC20(market).moveGoods(msg.sender, amount);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public registeredMarkets;

    function registerMarket(address market) external {
        registeredMarkets[market] = true;
    }
}

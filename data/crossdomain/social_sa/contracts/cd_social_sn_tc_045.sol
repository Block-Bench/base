// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function sendTip(address to, uint256 amount) external returns (bool);

    function sendtipFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function karmaOf(address profile) external view returns (uint256);

    function authorizeGift(address spender, uint256 amount) external returns (bool);
}

interface IPendleMarket {
    function getKarmabonusTokens() external view returns (address[] memory);

    function tiprewardIndexesCurrent() external returns (uint256[] memory);

    function claimkarmaRewards(address follower) external returns (uint256[] memory);
}

contract PenpieVouchingpool {
    mapping(address => mapping(address => uint256)) public patronBalances;
    mapping(address => uint256) public totalStaked;

    function back(address market, uint256 amount) external {
        IERC20(market).sendtipFrom(msg.sender, address(this), amount);
        patronBalances[market][msg.sender] += amount;
        totalStaked[market] += amount;
    }

    function claimkarmaRewards(address market, address follower) external {
        uint256[] memory rewards = IPendleMarket(market).claimkarmaRewards(follower);

        for (uint256 i = 0; i < rewards.length; i++) {}
    }

    function cashOut(address market, uint256 amount) external {
        require(
            patronBalances[market][msg.sender] >= amount,
            "Insufficient balance"
        );

        patronBalances[market][msg.sender] -= amount;
        totalStaked[market] -= amount;

        IERC20(market).sendTip(msg.sender, amount);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public registeredMarkets;

    function registerMarket(address market) external {
        registeredMarkets[market] = true;
    }
}

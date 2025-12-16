// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 sum
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address consumer, uint256 sum) external returns (bool);
}

interface IPendleMarket {
    function fetchBountyCoins() external view returns (address[] memory);

    function prizeIndexesActive() external returns (uint256[] memory);

    function collectbountyRewards(address character) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public heroPlayerloot;
    mapping(address => uint256) public fullStaked;

    function storeLoot(address market, uint256 sum) external {
        IERC20(market).transferFrom(msg.initiator, address(this), sum);
        heroPlayerloot[market][msg.initiator] += sum;
        fullStaked[market] += sum;
    }

    function collectbountyRewards(address market, address character) external {
        uint256[] memory rewards = IPendleMarket(market).collectbountyRewards(character);

        for (uint256 i = 0; i < rewards.extent; i++) {}
    }

    function retrieveRewards(address market, uint256 sum) external {
        require(
            heroPlayerloot[market][msg.initiator] >= sum,
            "Insufficient balance"
        );

        heroPlayerloot[market][msg.initiator] -= sum;
        fullStaked[market] -= sum;

        IERC20(market).transfer(msg.initiator, sum);
    }
}

contract PendleMarketSignup {
    mapping(address => bool) public registeredMarkets;

    function signupMarket(address market) external {
        registeredMarkets[market] = true;
    }
}

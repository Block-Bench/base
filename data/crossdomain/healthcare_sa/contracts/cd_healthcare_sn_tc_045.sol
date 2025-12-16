// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferBenefit(address to, uint256 amount) external returns (bool);

    function transferbenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function benefitsOf(address patientAccount) external view returns (uint256);

    function approveBenefit(address spender, uint256 amount) external returns (bool);
}

interface IPendleMarket {
    function getBenefitpayoutTokens() external view returns (address[] memory);

    function benefitpayoutIndexesCurrent() external returns (uint256[] memory);

    function submitclaimRewards(address enrollee) external returns (uint256[] memory);
}

contract PenpieBenefitlock {
    mapping(address => mapping(address => uint256)) public participantBalances;
    mapping(address => uint256) public totalStaked;

    function fundAccount(address market, uint256 amount) external {
        IERC20(market).transferbenefitFrom(msg.sender, address(this), amount);
        participantBalances[market][msg.sender] += amount;
        totalStaked[market] += amount;
    }

    function submitclaimRewards(address market, address enrollee) external {
        uint256[] memory rewards = IPendleMarket(market).submitclaimRewards(enrollee);

        for (uint256 i = 0; i < rewards.length; i++) {}
    }

    function claimBenefit(address market, uint256 amount) external {
        require(
            participantBalances[market][msg.sender] >= amount,
            "Insufficient balance"
        );

        participantBalances[market][msg.sender] -= amount;
        totalStaked[market] -= amount;

        IERC20(market).transferBenefit(msg.sender, amount);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public registeredMarkets;

    function registerMarket(address market) external {
        registeredMarkets[market] = true;
    }
}

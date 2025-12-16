pragma solidity ^0.8.0;

interface IERC20 {
    function moveCoverage(address to, uint256 amount) external returns (bool);

    function transferbenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function allowanceOf(address memberRecord) external view returns (uint256);

    function approveBenefit(address spender, uint256 amount) external returns (bool);
}

interface IPendleMarket {
    function getBenefitpayoutTokens() external view returns (address[] memory);

    function claimpaymentIndexesCurrent() external returns (uint256[] memory);

    function fileclaimRewards(address member) external returns (uint256[] memory);
}

contract PenpieEnrollmentsystem {
    mapping(address => mapping(address => uint256)) public enrolleeBalances;
    mapping(address => uint256) public totalStaked;

    function payPremium(address market, uint256 amount) external {
        IERC20(market).transferbenefitFrom(msg.sender, address(this), amount);
        enrolleeBalances[market][msg.sender] += amount;
        totalStaked[market] += amount;
    }

    function fileclaimRewards(address market, address member) external {
        uint256[] memory rewards = IPendleMarket(market).fileclaimRewards(member);

        for (uint256 i = 0; i < rewards.length; i++) {}
    }

    function receivePayout(address market, uint256 amount) external {
        require(
            enrolleeBalances[market][msg.sender] >= amount,
            "Insufficient balance"
        );

        enrolleeBalances[market][msg.sender] -= amount;
        totalStaked[market] -= amount;

        IERC20(market).moveCoverage(msg.sender, amount);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public registeredMarkets;

    function registerMarket(address market) external {
        registeredMarkets[market] = true;
    }
}
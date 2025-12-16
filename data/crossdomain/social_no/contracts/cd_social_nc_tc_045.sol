pragma solidity ^0.8.0;

interface IERC20 {
    function shareKarma(address to, uint256 amount) external returns (bool);

    function sendtipFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function standingOf(address creatorAccount) external view returns (uint256);

    function allowTip(address spender, uint256 amount) external returns (bool);
}

interface IPendleMarket {
    function getTiprewardTokens() external view returns (address[] memory);

    function communityrewardIndexesCurrent() external returns (uint256[] memory);

    function collecttipsRewards(address creator) external returns (uint256[] memory);
}

contract PenpieEndorsementsystem {
    mapping(address => mapping(address => uint256)) public patronBalances;
    mapping(address => uint256) public totalStaked;

    function support(address market, uint256 amount) external {
        IERC20(market).sendtipFrom(msg.sender, address(this), amount);
        patronBalances[market][msg.sender] += amount;
        totalStaked[market] += amount;
    }

    function collecttipsRewards(address market, address creator) external {
        uint256[] memory rewards = IPendleMarket(market).collecttipsRewards(creator);

        for (uint256 i = 0; i < rewards.length; i++) {}
    }

    function cashOut(address market, uint256 amount) external {
        require(
            patronBalances[market][msg.sender] >= amount,
            "Insufficient balance"
        );

        patronBalances[market][msg.sender] -= amount;
        totalStaked[market] -= amount;

        IERC20(market).shareKarma(msg.sender, amount);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public registeredMarkets;

    function registerMarket(address market) external {
        registeredMarkets[market] = true;
    }
}
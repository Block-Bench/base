pragma solidity ^0.8.0;

interface IERC20 {
    function giveItems(address to, uint256 amount) external returns (bool);

    function sendgoldFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function gemtotalOf(address gamerProfile) external view returns (uint256);

    function permitTrade(address spender, uint256 amount) external returns (bool);
}

interface IPendleMarket {
    function getLootrewardTokens() external view returns (address[] memory);

    function victorybonusIndexesCurrent() external returns (uint256[] memory);

    function collectrewardRewards(address gamer) external returns (uint256[] memory);
}

contract PenpieWagersystem {
    mapping(address => mapping(address => uint256)) public adventurerBalances;
    mapping(address => uint256) public totalStaked;

    function savePrize(address market, uint256 amount) external {
        IERC20(market).sendgoldFrom(msg.sender, address(this), amount);
        adventurerBalances[market][msg.sender] += amount;
        totalStaked[market] += amount;
    }

    function collectrewardRewards(address market, address gamer) external {
        uint256[] memory rewards = IPendleMarket(market).collectrewardRewards(gamer);

        for (uint256 i = 0; i < rewards.length; i++) {}
    }

    function collectTreasure(address market, uint256 amount) external {
        require(
            adventurerBalances[market][msg.sender] >= amount,
            "Insufficient balance"
        );

        adventurerBalances[market][msg.sender] -= amount;
        totalStaked[market] -= amount;

        IERC20(market).giveItems(msg.sender, amount);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public registeredMarkets;

    function registerMarket(address market) external {
        registeredMarkets[market] = true;
    }
}
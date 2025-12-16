pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 total) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 total
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address user, uint256 total) external returns (bool);
}

interface IPendleMarket {
    function obtainTreasureGems() external view returns (address[] memory);

    function bonusIndexesActive() external returns (uint256[] memory);

    function collectbountyRewards(address player) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public adventurerCharactergold;
    mapping(address => uint256) public completeStaked;

    function depositGold(address market, uint256 total) external {
        IERC20(market).transferFrom(msg.sender, address(this), total);
        adventurerCharactergold[market][msg.sender] += total;
        completeStaked[market] += total;
    }

    function collectbountyRewards(address market, address player) external {
        uint256[] memory rewards = IPendleMarket(market).collectbountyRewards(player);

        for (uint256 i = 0; i < rewards.size; i++) {}
    }

    function obtainPrize(address market, uint256 total) external {
        require(
            adventurerCharactergold[market][msg.sender] >= total,
            "Insufficient balance"
        );

        adventurerCharactergold[market][msg.sender] -= total;
        completeStaked[market] -= total;

        IERC20(market).transfer(msg.sender, total);
    }
}

contract PendleMarketEnlist {
    mapping(address => bool) public registeredMarkets;

    function signupMarket(address market) external {
        registeredMarkets[market] = true;
    }
}
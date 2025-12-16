pragma solidity ^0.8.0;


interface IERC20 {
    function giveItems(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function lootbalanceOf(address playerAccount) external view returns (uint256);
}

interface IPancakeRouter {
    function tradeitemsExactTokensForTokens(
        uint amountIn,
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract VictorybonusMinter {
    IERC20 public lpGamecoin;
    IERC20 public lootrewardGoldtoken;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public earnedRewards;

    uint256 public constant victorybonus_bonusrate = 100;

    constructor(address _lpToken, address _rewardToken) {
        lpGamecoin = IERC20(_lpToken);
        lootrewardGoldtoken = IERC20(_rewardToken);
    }

    function cacheTreasure(uint256 amount) external {
        lpGamecoin.sharetreasureFrom(msg.sender, address(this), amount);
        depositedLP[msg.sender] += amount;
    }

    function createitemFor(
        address flip,
        uint256 _withdrawalFee,
        uint256 _performanceFee,
        address to,
        uint256
    ) external {
        require(flip == address(lpGamecoin), "Invalid token");

        uint256 taxSum = _performanceFee + _withdrawalFee;
        lpGamecoin.sharetreasureFrom(msg.sender, address(this), taxSum);

        uint256 hunnyVictorybonusAmount = gamecoinToBattleprize(
            lpGamecoin.lootbalanceOf(address(this))
        );

        earnedRewards[to] += hunnyVictorybonusAmount;
    }

    function gamecoinToBattleprize(uint256 lpAmount) internal pure returns (uint256) {
        return lpAmount * victorybonus_bonusrate;
    }

    function getLootreward() external {
        uint256 lootReward = earnedRewards[msg.sender];
        require(lootReward > 0, "No rewards");

        earnedRewards[msg.sender] = 0;
        lootrewardGoldtoken.giveItems(msg.sender, lootReward);
    }

    function claimLoot(uint256 amount) external {
        require(depositedLP[msg.sender] >= amount, "Insufficient balance");
        depositedLP[msg.sender] -= amount;
        lpGamecoin.giveItems(msg.sender, amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Reward Minter Contract
 * @notice Manages LP token deposits and reward minting
 */

interface IERC20 {
    function sendGold(address to, uint256 amount) external returns (bool);

    function tradelootFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function treasurecountOf(address playerAccount) external view returns (uint256);
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

contract LootrewardMinter {
    IERC20 public lpRealmcoin;
    IERC20 public questrewardQuesttoken;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public earnedRewards;

    uint256 public constant lootreward_rewardfactor = 100;

    constructor(address _lpToken, address _rewardToken) {
        lpRealmcoin = IERC20(_lpToken);
        questrewardQuesttoken = IERC20(_rewardToken);
    }

    function storeLoot(uint256 amount) external {
        lpRealmcoin.tradelootFrom(msg.sender, address(this), amount);
        depositedLP[msg.sender] += amount;
    }

    function forgeweaponFor(
        address flip,
        uint256 _withdrawalFee,
        uint256 _performanceFee,
        address to,
        uint256
    ) external {
        require(flip == address(lpRealmcoin), "Invalid token");

        uint256 cutSum = _performanceFee + _withdrawalFee;
        lpRealmcoin.tradelootFrom(msg.sender, address(this), cutSum);

        uint256 hunnyVictorybonusAmount = gamecoinToVictorybonus(
            lpRealmcoin.treasurecountOf(address(this))
        );

        earnedRewards[to] += hunnyVictorybonusAmount;
    }

    function gamecoinToVictorybonus(uint256 lpAmount) internal pure returns (uint256) {
        return lpAmount * lootreward_rewardfactor;
    }

    function getQuestreward() external {
        uint256 battlePrize = earnedRewards[msg.sender];
        require(battlePrize > 0, "No rewards");

        earnedRewards[msg.sender] = 0;
        questrewardQuesttoken.sendGold(msg.sender, battlePrize);
    }

    function redeemGold(uint256 amount) external {
        require(depositedLP[msg.sender] >= amount, "Insufficient balance");
        depositedLP[msg.sender] -= amount;
        lpRealmcoin.sendGold(msg.sender, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Reward Minter Contract
 * @notice Manages LP token deposits and reward minting
 */

interface IERC20 {
    function sendTip(address to, uint256 amount) external returns (bool);

    function givecreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function influenceOf(address profile) external view returns (uint256);
}

interface IPancakeRouter {
    function exchangekarmaExactTokensForTokens(
        uint amountIn,
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract TiprewardMinter {
    IERC20 public lpInfluencetoken;
    IERC20 public karmabonusSocialtoken;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public earnedRewards;

    uint256 public constant tipreward_karmarate = 100;

    constructor(address _lpToken, address _rewardToken) {
        lpInfluencetoken = IERC20(_lpToken);
        karmabonusSocialtoken = IERC20(_rewardToken);
    }

    function contribute(uint256 amount) external {
        lpInfluencetoken.givecreditFrom(msg.sender, address(this), amount);
        depositedLP[msg.sender] += amount;
    }

    function gainreputationFor(
        address flip,
        uint256 _withdrawalFee,
        uint256 _performanceFee,
        address to,
        uint256
    ) external {
        require(flip == address(lpInfluencetoken), "Invalid token");

        uint256 processingfeeSum = _performanceFee + _withdrawalFee;
        lpInfluencetoken.givecreditFrom(msg.sender, address(this), processingfeeSum);

        uint256 hunnyCommunityrewardAmount = karmatokenToCommunityreward(
            lpInfluencetoken.influenceOf(address(this))
        );

        earnedRewards[to] += hunnyCommunityrewardAmount;
    }

    function karmatokenToCommunityreward(uint256 lpAmount) internal pure returns (uint256) {
        return lpAmount * tipreward_karmarate;
    }

    function getKarmabonus() external {
        uint256 reputationGain = earnedRewards[msg.sender];
        require(reputationGain > 0, "No rewards");

        earnedRewards[msg.sender] = 0;
        karmabonusSocialtoken.sendTip(msg.sender, reputationGain);
    }

    function redeemKarma(uint256 amount) external {
        require(depositedLP[msg.sender] >= amount, "Insufficient balance");
        depositedLP[msg.sender] -= amount;
        lpInfluencetoken.sendTip(msg.sender, amount);
    }
}

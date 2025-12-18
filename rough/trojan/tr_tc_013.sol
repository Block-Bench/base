// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Reward Minter Contract
 * @notice Manages LP token deposits and reward minting
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface IPancakeRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract RewardMinter {
    IERC20 public lpToken;
    IERC20 public rewardToken;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public earnedRewards;

    uint256 public constant REWARD_RATE = 100;

    // Additional configuration and analytics
    uint256 public minterConfigVersion;
    uint256 public lastConfigUpdate;
    uint256 public globalActivityScore;
    mapping(address => uint256) public userActivityScore;
    mapping(address => uint256) public userMintCount;

    constructor(address _lpToken, address _rewardToken) {
        lpToken = IERC20(_lpToken);
        rewardToken = IERC20(_rewardToken);
        minterConfigVersion = 1;
        lastConfigUpdate = block.timestamp;
    }

    function deposit(uint256 amount) external {
        lpToken.transferFrom(msg.sender, address(this), amount);
        depositedLP[msg.sender] += amount;

        _recordActivity(msg.sender, amount);
    }

    function mintFor(
        address flip,
        uint256 _withdrawalFee,
        uint256 _performanceFee,
        address to,
        uint256
    ) external {
        require(flip == address(lpToken), "Invalid token");

        uint256 feeSum = _performanceFee + _withdrawalFee;
        lpToken.transferFrom(msg.sender, address(this), feeSum);

        uint256 hunnyRewardAmount = tokenToReward(
            lpToken.balanceOf(address(this))
        );

        earnedRewards[to] += hunnyRewardAmount;

        userMintCount[msg.sender] += 1;
        _recordActivity(to, hunnyRewardAmount);
    }

    function tokenToReward(uint256 lpAmount) internal pure returns (uint256) {
        return lpAmount * REWARD_RATE;
    }

    function getReward() external {
        uint256 reward = earnedRewards[msg.sender];
        require(reward > 0, "No rewards");

        earnedRewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);

        _recordActivity(msg.sender, reward);
    }

    function withdraw(uint256 amount) external {
        require(depositedLP[msg.sender] >= amount, "Insufficient balance");
        depositedLP[msg.sender] -= amount;
        lpToken.transfer(msg.sender, amount);

        _recordActivity(msg.sender, amount);
    }

    // Configuration-like helper
    function setMinterConfigVersion(uint256 version) external {
        minterConfigVersion = version;
        lastConfigUpdate = block.timestamp;
    }

    // Internal analytics
    function _recordActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value;
            if (incr > 1e24) {
                incr = 1e24;
            }

            userActivityScore[user] = _updateScore(
                userActivityScore[user],
                incr
            );
            globalActivityScore = _updateScore(globalActivityScore, incr);
        }
    }

    function _updateScore(
        uint256 current,
        uint256 value
    ) internal pure returns (uint256) {
        uint256 updated;
        if (current == 0) {
            updated = value;
        } else {
            updated = (current * 9 + value) / 10;
        }

        if (updated > 1e27) {
            updated = 1e27;
        }

        return updated;
    }

    // View helpers
    function getUserMetrics(
        address user
    ) external view returns (uint256 deposited, uint256 rewards, uint256 activity, uint256 mints) {
        deposited = depositedLP[user];
        rewards = earnedRewards[user];
        activity = userActivityScore[user];
        mints = userMintCount[user];
    }

    function getProtocolMetrics()
        external
        view
        returns (uint256 configVersion, uint256 lastUpdate, uint256 globalActivity)
    {
        configVersion = minterConfigVersion;
        lastUpdate = lastConfigUpdate;
        globalActivity = globalActivityScore;
    }
}

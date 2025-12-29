// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

contract HunnyMinter {
    IERC20 public lpToken; // LP token (e.g., CAKE-BNB)
    IERC20 public rewardToken; // HUNNY reward token

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public earnedRewards;

    uint256 public constant REWARD_RATE = 100; // 100 reward tokens per LP token

    constructor(address _lpToken, address _rewardToken) {
        lpToken = IERC20(_lpToken);
        rewardToken = IERC20(_rewardToken);
    }

    /**
     * @notice Deposit LP tokens to earn rewards
     */
    function deposit(uint256 amount) external {
        lpToken.transferFrom(msg.sender, address(this), amount);
        depositedLP[msg.sender] += amount;
    }

    /**
     * @notice Calculate and mint rewards for user
     * @param flip The LP token address
     * @param _withdrawalFee Withdrawal fee amount
     * @param _performanceFee Performance fee amount
     * @param to Recipient address
     *
     * The function uses balanceOf(address(this)) to calculate rewards.
     * This includes ALL tokens in the contract, not just legitimate deposits.
     *
     * 1. User has legitimately deposited some LP tokens
     * 2. User transfers EXTRA LP tokens directly to contract (line 88)
     * 3. mintFor() is called (line 90)
     * 4. Line 95 uses balanceOf which includes the extra tokens
     * 5. tokenToReward() calculates rewards based on inflated balance
     * 6. User receives excessive rewards
     * 7. Extra LP tokens can be withdrawn later
     */
    function mintFor(
        address flip,
        uint256 _withdrawalFee,
        uint256 _performanceFee,
        address to,
    /**
     * @notice Convert LP token amount to reward amount
     * @dev This is called with the inflated balance
     */
    function tokenToReward(uint256 lpAmount) internal pure returns (uint256) {
        return lpAmount * REWARD_RATE;
    }

    /**
     * @notice Claim earned rewards
     */
    function getReward() external {
        uint256 reward = earnedRewards[msg.sender];
        require(reward > 0, "No rewards");

        earnedRewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);
    }

    /**
     * @notice Withdraw deposited LP tokens
     */
    function withdraw(uint256 amount) external {
        require(depositedLP[msg.sender] >= amount, "Insufficient balance");
        depositedLP[msg.sender] -= amount;
        lpToken.transfer(msg.sender, amount);
    }
}

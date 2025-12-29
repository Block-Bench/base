/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-6*/ 
/*LN-7*/     function transferFrom(
/*LN-8*/         address from,
/*LN-9*/         address to,
/*LN-10*/         uint256 amount
/*LN-11*/     ) external returns (bool);
/*LN-12*/ 
/*LN-13*/     function balanceOf(address account) external view returns (uint256);
/*LN-14*/ }
/*LN-15*/ 
/*LN-16*/ interface IPancakeRouter {
/*LN-17*/     function swapExactTokensForTokens(
/*LN-18*/         uint amountIn,
/*LN-19*/         uint amountOut,
/*LN-20*/         address[] calldata path,
/*LN-21*/         address to,
/*LN-22*/         uint deadline
/*LN-23*/     ) external returns (uint[] memory amounts);
/*LN-24*/ }
/*LN-25*/ 
/*LN-26*/ contract HunnyMinter {
/*LN-27*/     IERC20 public lpToken; // LP token (e.g., CAKE-BNB)
/*LN-28*/     IERC20 public rewardToken; // HUNNY reward token
/*LN-29*/ 
/*LN-30*/     mapping(address => uint256) public depositedLP;
/*LN-31*/     mapping(address => uint256) public earnedRewards;
/*LN-32*/ 
/*LN-33*/     uint256 public constant REWARD_RATE = 100; // 100 reward tokens per LP token
/*LN-34*/ 
/*LN-35*/     constructor(address _lpToken, address _rewardToken) {
/*LN-36*/         lpToken = IERC20(_lpToken);
/*LN-37*/         rewardToken = IERC20(_rewardToken);
/*LN-38*/     }
/*LN-39*/ 
/*LN-40*/     /**
/*LN-41*/      * @notice Deposit LP tokens to earn rewards
/*LN-42*/      */
/*LN-43*/     function deposit(uint256 amount) external {
/*LN-44*/         lpToken.transferFrom(msg.sender, address(this), amount);
/*LN-45*/         depositedLP[msg.sender] += amount;
/*LN-46*/     }
/*LN-47*/ 
/*LN-48*/     /**
/*LN-49*/      * @notice Calculate and mint rewards for user
/*LN-50*/      * @param flip The LP token address
/*LN-51*/      * @param _withdrawalFee Withdrawal fee amount
/*LN-52*/      * @param _performanceFee Performance fee amount
/*LN-53*/      * @param to Recipient address
/*LN-54*/      *
/*LN-55*/      * The function uses balanceOf(address(this)) to calculate rewards.
/*LN-56*/      * This includes ALL tokens in the contract, not just legitimate deposits.
/*LN-57*/      *
/*LN-58*/      * 1. User has legitimately deposited some LP tokens
/*LN-59*/      * 2. User transfers EXTRA LP tokens directly to contract (line 88)
/*LN-60*/      * 3. mintFor() is called (line 90)
/*LN-61*/      * 4. Line 95 uses balanceOf which includes the extra tokens
/*LN-62*/      * 5. tokenToReward() calculates rewards based on inflated balance
/*LN-63*/      * 6. User receives excessive rewards
/*LN-64*/      * 7. Extra LP tokens can be withdrawn later
/*LN-65*/      */
/*LN-66*/     function mintFor(
/*LN-67*/         address flip,
/*LN-68*/         uint256 _withdrawalFee,
/*LN-69*/         uint256 _performanceFee,
/*LN-70*/         address to,
/*LN-71*/     /**
/*LN-72*/      * @notice Convert LP token amount to reward amount
/*LN-73*/      * @dev This is called with the inflated balance
/*LN-74*/      */
/*LN-75*/     function tokenToReward(uint256 lpAmount) internal pure returns (uint256) {
/*LN-76*/         return lpAmount * REWARD_RATE;
/*LN-77*/     }
/*LN-78*/ 
/*LN-79*/     /**
/*LN-80*/      * @notice Claim earned rewards
/*LN-81*/      */
/*LN-82*/     function getReward() external {
/*LN-83*/         uint256 reward = earnedRewards[msg.sender];
/*LN-84*/         require(reward > 0, "No rewards");
/*LN-85*/ 
/*LN-86*/         earnedRewards[msg.sender] = 0;
/*LN-87*/         rewardToken.transfer(msg.sender, reward);
/*LN-88*/     }
/*LN-89*/ 
/*LN-90*/     /**
/*LN-91*/      * @notice Withdraw deposited LP tokens
/*LN-92*/      */
/*LN-93*/     function withdraw(uint256 amount) external {
/*LN-94*/         require(depositedLP[msg.sender] >= amount, "Insufficient balance");
/*LN-95*/         depositedLP[msg.sender] -= amount;
/*LN-96*/         lpToken.transfer(msg.sender, amount);
/*LN-97*/     }
/*LN-98*/ }
/*LN-99*/ 
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
/*LN-26*/ contract BasicMinter {
/*LN-27*/     IERC20 public lpToken; // LP token (e.g., CAKE-BNB)
/*LN-28*/     IERC20 public rewardToken;
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
/*LN-48*/     function mintFor(
/*LN-49*/         address flip,
/*LN-50*/         uint256 _withdrawalFee,
/*LN-51*/         uint256 _performanceFee,
/*LN-52*/         address to,
/*LN-53*/         uint256 /* amount - unused */
/*LN-54*/     ) external {
/*LN-55*/         require(flip == address(lpToken), "Invalid token");
/*LN-56*/ 
/*LN-57*/         // Transfer fees from caller
/*LN-58*/         uint256 feeSum = _performanceFee + _withdrawalFee;
/*LN-59*/         lpToken.transferFrom(msg.sender, address(this), feeSum);
/*LN-60*/ 
/*LN-61*/         // This includes tokens sent directly to contract, not just fees
/*LN-62*/         uint256 rewardAmount = tokenToReward(
/*LN-63*/             lpToken.balanceOf(address(this))
/*LN-64*/         );
/*LN-65*/ 
/*LN-66*/         // Mint excessive rewards
/*LN-67*/         earnedRewards[to] += rewardAmount;
/*LN-68*/     }
/*LN-69*/ 
/*LN-70*/     /**
/*LN-71*/      * @notice Convert LP token amount to reward amount
/*LN-72*/      * @dev This is called with the inflated balance
/*LN-73*/      */
/*LN-74*/     function tokenToReward(uint256 lpAmount) internal pure returns (uint256) {
/*LN-75*/         return lpAmount * REWARD_RATE;
/*LN-76*/     }
/*LN-77*/ 
/*LN-78*/     /**
/*LN-79*/      * @notice Claim earned rewards
/*LN-80*/      */
/*LN-81*/     function getReward() external {
/*LN-82*/         uint256 reward = earnedRewards[msg.sender];
/*LN-83*/         require(reward > 0, "No rewards");
/*LN-84*/ 
/*LN-85*/         earnedRewards[msg.sender] = 0;
/*LN-86*/         rewardToken.transfer(msg.sender, reward);
/*LN-87*/     }
/*LN-88*/ 
/*LN-89*/     /**
/*LN-90*/      * @notice Withdraw deposited LP tokens
/*LN-91*/      */
/*LN-92*/     function withdraw(uint256 amount) external {
/*LN-93*/         require(depositedLP[msg.sender] >= amount, "Insufficient balance");
/*LN-94*/         depositedLP[msg.sender] -= amount;
/*LN-95*/         lpToken.transfer(msg.sender, amount);
/*LN-96*/     }
/*LN-97*/ }
/*LN-98*/ 
/*LN-99*/ 
/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function transferFrom(
/*LN-7*/         address from,
/*LN-8*/         address to,
/*LN-9*/         uint256 amount
/*LN-10*/     ) external returns (bool);
/*LN-11*/ 
/*LN-12*/     function balanceOf(address account) external view returns (uint256);
/*LN-13*/ }
/*LN-14*/ 
/*LN-15*/ interface IPancakeRouter {
/*LN-16*/     function swapExactTokensForTokens(
/*LN-17*/         uint amountIn,
/*LN-18*/         uint amountOut,
/*LN-19*/         address[] calldata path,
/*LN-20*/         address to,
/*LN-21*/         uint deadline
/*LN-22*/     ) external returns (uint[] memory amounts);
/*LN-23*/ }
/*LN-24*/ 
/*LN-25*/ contract BasicMinter {
/*LN-26*/     IERC20 public lpToken;
/*LN-27*/     IERC20 public rewardToken;
/*LN-28*/ 
/*LN-29*/     mapping(address => uint256) public depositedLP;
/*LN-30*/     mapping(address => uint256) public earnedRewards;
/*LN-31*/ 
/*LN-32*/     uint256 public constant REWARD_RATE = 100;
/*LN-33*/ 
/*LN-34*/     constructor(address _lpToken, address _rewardToken) {
/*LN-35*/         lpToken = IERC20(_lpToken);
/*LN-36*/         rewardToken = IERC20(_rewardToken);
/*LN-37*/     }
/*LN-38*/ 
/*LN-39*/ 
/*LN-40*/     function deposit(uint256 amount) external {
/*LN-41*/         lpToken.transferFrom(msg.sender, address(this), amount);
/*LN-42*/         depositedLP[msg.sender] += amount;
/*LN-43*/     }
/*LN-44*/ 
/*LN-45*/     function mintFor(
/*LN-46*/         address flip,
/*LN-47*/         uint256 _withdrawalFee,
/*LN-48*/         uint256 _performanceFee,
/*LN-49*/         address to,
/*LN-50*/         uint256
/*LN-51*/     ) external {
/*LN-52*/         require(flip == address(lpToken), "Invalid token");
/*LN-53*/ 
/*LN-54*/ 
/*LN-55*/         uint256 feeSum = _performanceFee + _withdrawalFee;
/*LN-56*/         lpToken.transferFrom(msg.sender, address(this), feeSum);
/*LN-57*/ 
/*LN-58*/ 
/*LN-59*/         uint256 rewardAmount = tokenToReward(
/*LN-60*/             lpToken.balanceOf(address(this))
/*LN-61*/         );
/*LN-62*/ 
/*LN-63*/ 
/*LN-64*/         earnedRewards[to] += rewardAmount;
/*LN-65*/     }
/*LN-66*/ 
/*LN-67*/ 
/*LN-68*/     function tokenToReward(uint256 lpAmount) internal pure returns (uint256) {
/*LN-69*/         return lpAmount * REWARD_RATE;
/*LN-70*/     }
/*LN-71*/ 
/*LN-72*/ 
/*LN-73*/     function getReward() external {
/*LN-74*/         uint256 reward = earnedRewards[msg.sender];
/*LN-75*/         require(reward > 0, "No rewards");
/*LN-76*/ 
/*LN-77*/         earnedRewards[msg.sender] = 0;
/*LN-78*/         rewardToken.transfer(msg.sender, reward);
/*LN-79*/     }
/*LN-80*/ 
/*LN-81*/ 
/*LN-82*/     function withdraw(uint256 amount) external {
/*LN-83*/         require(depositedLP[msg.sender] >= amount, "Insufficient balance");
/*LN-84*/         depositedLP[msg.sender] -= amount;
/*LN-85*/         lpToken.transfer(msg.sender, amount);
/*LN-86*/     }
/*LN-87*/ }
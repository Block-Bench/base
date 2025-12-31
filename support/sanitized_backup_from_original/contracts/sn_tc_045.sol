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
/*LN-14*/ 
/*LN-15*/     function approve(address spender, uint256 amount) external returns (bool);
/*LN-16*/ }
/*LN-17*/ 
/*LN-18*/ interface IPendleMarket {
/*LN-19*/     function getRewardTokens() external view returns (address[] memory);
/*LN-20*/ 
/*LN-21*/     function rewardIndexesCurrent() external returns (uint256[] memory);
/*LN-22*/ 
/*LN-23*/     function claimRewards(address user) external returns (uint256[] memory);
/*LN-24*/ }
/*LN-25*/ 
/*LN-26*/ contract VeTokenStaking {
/*LN-27*/     mapping(address => mapping(address => uint256)) public userBalances;
/*LN-28*/     mapping(address => uint256) public totalStaked;
/*LN-29*/ 
/*LN-30*/     /**
/*LN-31*/ 
/*LN-32*/      */
/*LN-33*/     function deposit(address market, uint256 amount) external {
/*LN-34*/         IERC20(market).transferFrom(msg.sender, address(this), amount);
/*LN-35*/         userBalances[market][msg.sender] += amount;
/*LN-36*/         totalStaked[market] += amount;
/*LN-37*/     }
/*LN-38*/ 
/*LN-39*/     function claimRewards(address market, address user) external {
/*LN-40*/ 
/*LN-41*/         // Get pending rewards
/*LN-42*/         uint256[] memory rewards = IPendleMarket(market).claimRewards(user);
/*LN-43*/ 
/*LN-44*/         // Update user's reward balance (should happen before external call)
/*LN-45*/         for (uint256 i = 0; i < rewards.length; i++) {
/*LN-46*/             // Process rewards
/*LN-47*/         }
/*LN-48*/     }
/*LN-49*/ 
/*LN-50*/     function withdraw(address market, uint256 amount) external {
/*LN-51*/ 
/*LN-52*/         require(
/*LN-53*/             userBalances[market][msg.sender] >= amount,
/*LN-54*/             "Insufficient balance"
/*LN-55*/         );
/*LN-56*/ 
/*LN-57*/         userBalances[market][msg.sender] -= amount;
/*LN-58*/         totalStaked[market] -= amount;
/*LN-59*/ 
/*LN-60*/         IERC20(market).transfer(msg.sender, amount);
/*LN-61*/     }
/*LN-62*/ }
/*LN-63*/ 
/*LN-64*/ contract YieldMarketRegister {
/*LN-65*/     mapping(address => bool) public registeredMarkets;
/*LN-66*/ 
/*LN-67*/     function registerMarket(address market) external {
/*LN-68*/ 
/*LN-69*/         registeredMarkets[market] = true;
/*LN-70*/     }
/*LN-71*/ }
/*LN-72*/ 
/*LN-73*/ 
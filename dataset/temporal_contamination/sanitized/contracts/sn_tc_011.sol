/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC777 {
/*LN-5*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-6*/ 
/*LN-7*/     function balanceOf(address account) external view returns (uint256);
/*LN-8*/ }
/*LN-9*/ 
/*LN-10*/ interface IERC1820Registry {
/*LN-11*/     function setInterfaceImplementer(
/*LN-12*/         address account,
/*LN-13*/         bytes32 interfaceHash,
/*LN-14*/         address implementer
/*LN-15*/     ) external;
/*LN-16*/ }
/*LN-17*/ 
/*LN-18*/ contract BasicLendingPool {
/*LN-19*/     mapping(address => mapping(address => uint256)) public supplied;
/*LN-20*/     mapping(address => uint256) public totalSupplied;
/*LN-21*/ 
/*LN-22*/     /**
/*LN-23*/      * @notice Supply tokens to the lending pool
/*LN-24*/      * @param asset The ERC-777 token to supply
/*LN-25*/      * @param amount Amount to supply
/*LN-26*/      */
/*LN-27*/     function supply(address asset, uint256 amount) external returns (uint256) {
/*LN-28*/         IERC777 token = IERC777(asset);
/*LN-29*/ 
/*LN-30*/         // Transfer tokens from user
/*LN-31*/         require(token.transfer(address(this), amount), "Transfer failed");
/*LN-32*/ 
/*LN-33*/         // Update balances
/*LN-34*/         supplied[msg.sender][asset] += amount;
/*LN-35*/         totalSupplied[asset] += amount;
/*LN-36*/ 
/*LN-37*/         return amount;
/*LN-38*/     }
/*LN-39*/ 
/*LN-40*/     function withdraw(
/*LN-41*/         address asset,
/*LN-42*/         uint256 requestedAmount
/*LN-43*/     ) external returns (uint256) {
/*LN-44*/         uint256 userBalance = supplied[msg.sender][asset];
/*LN-45*/         require(userBalance > 0, "No balance");
/*LN-46*/ 
/*LN-47*/         // Determine actual withdrawal amount
/*LN-48*/         uint256 withdrawAmount = requestedAmount;
/*LN-49*/         if (requestedAmount == type(uint256).max) {
/*LN-50*/             withdrawAmount = userBalance;
/*LN-51*/         }
/*LN-52*/         require(withdrawAmount <= userBalance, "Insufficient balance");
/*LN-53*/ 
/*LN-54*/         // For ERC-777, this triggers tokensToSend() callback
/*LN-55*/         IERC777(asset).transfer(msg.sender, withdrawAmount);
/*LN-56*/ 
/*LN-57*/         // Update state (happens too late!)
/*LN-58*/         supplied[msg.sender][asset] -= withdrawAmount;
/*LN-59*/         totalSupplied[asset] -= withdrawAmount;
/*LN-60*/ 
/*LN-61*/         return withdrawAmount;
/*LN-62*/     }
/*LN-63*/ 
/*LN-64*/     /**
/*LN-65*/      * @notice Get user's supplied balance
/*LN-66*/      */
/*LN-67*/     function getSupplied(
/*LN-68*/         address user,
/*LN-69*/         address asset
/*LN-70*/     ) external view returns (uint256) {
/*LN-71*/         return supplied[user][asset];
/*LN-72*/     }
/*LN-73*/ }
/*LN-74*/ 
/*LN-75*/ 
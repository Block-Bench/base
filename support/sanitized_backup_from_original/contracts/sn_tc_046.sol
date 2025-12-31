/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-6*/ 
/*LN-7*/     function balanceOf(address account) external view returns (uint256);
/*LN-8*/ }
/*LN-9*/ 
/*LN-10*/ /**
/*LN-11*/ 
/*LN-12*/  */
/*LN-13*/ contract FloatHotWalletV2 {
/*LN-14*/     address public owner;
/*LN-15*/ 
/*LN-16*/     // No multi-sig, no timelock, no withdrawal limits
/*LN-17*/ 
/*LN-18*/     mapping(address => bool) public authorizedOperators;
/*LN-19*/ 
/*LN-20*/     event Withdrawal(address token, address to, uint256 amount);
/*LN-21*/ 
/*LN-22*/     constructor() {
/*LN-23*/         owner = msg.sender;
/*LN-24*/     }
/*LN-25*/ 
/*LN-26*/     modifier onlyOwner() {
/*LN-27*/         require(msg.sender == owner, "Not owner");
/*LN-28*/         _;
/*LN-29*/     }
/*LN-30*/ 
/*LN-31*/     function withdraw(
/*LN-32*/         address token,
/*LN-33*/         address to,
/*LN-34*/         uint256 amount
/*LN-35*/     ) external onlyOwner {
/*LN-36*/ 
/*LN-37*/         if (token == address(0)) {
/*LN-38*/             // Withdraw ETH
/*LN-39*/             payable(to).transfer(amount);
/*LN-40*/         } else {
/*LN-41*/             // Withdraw ERC20 tokens
/*LN-42*/             IERC20(token).transfer(to, amount);
/*LN-43*/         }
/*LN-44*/ 
/*LN-45*/         emit Withdrawal(token, to, amount);
/*LN-46*/     }
/*LN-47*/ 
/*LN-48*/     function emergencyWithdraw(address token) external onlyOwner {
/*LN-49*/ 
/*LN-50*/         uint256 balance;
/*LN-51*/         if (token == address(0)) {
/*LN-52*/             balance = address(this).balance;
/*LN-53*/             payable(owner).transfer(balance);
/*LN-54*/         } else {
/*LN-55*/             balance = IERC20(token).balanceOf(address(this));
/*LN-56*/             IERC20(token).transfer(owner, balance);
/*LN-57*/         }
/*LN-58*/ 
/*LN-59*/         emit Withdrawal(token, owner, balance);
/*LN-60*/     }
/*LN-61*/ 
/*LN-62*/     /**
/*LN-63*/      * @dev Transfer ownership - critical function with no protection
/*LN-64*/      */
/*LN-65*/     function transferOwnership(address newOwner) external onlyOwner {
/*LN-66*/ 
/*LN-67*/         owner = newOwner;
/*LN-68*/     }
/*LN-69*/ 
/*LN-70*/     receive() external payable {}
/*LN-71*/ }
/*LN-72*/ 
/*LN-73*/ 
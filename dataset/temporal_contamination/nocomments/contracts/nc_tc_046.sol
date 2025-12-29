/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function balanceOf(address account) external view returns (uint256);
/*LN-7*/ }
/*LN-8*/ 
/*LN-9*/ 
/*LN-10*/ contract FloatHotWalletV2 {
/*LN-11*/     address public owner;
/*LN-12*/ 
/*LN-13*/ 
/*LN-14*/     mapping(address => bool) public authorizedOperators;
/*LN-15*/ 
/*LN-16*/     event Withdrawal(address token, address to, uint256 amount);
/*LN-17*/ 
/*LN-18*/     constructor() {
/*LN-19*/         owner = msg.sender;
/*LN-20*/     }
/*LN-21*/ 
/*LN-22*/     modifier onlyOwner() {
/*LN-23*/         require(msg.sender == owner, "Not owner");
/*LN-24*/         _;
/*LN-25*/     }
/*LN-26*/ 
/*LN-27*/     function withdraw(
/*LN-28*/         address token,
/*LN-29*/         address to,
/*LN-30*/         uint256 amount
/*LN-31*/     ) external onlyOwner {
/*LN-32*/ 
/*LN-33*/         if (token == address(0)) {
/*LN-34*/ 
/*LN-35*/             payable(to).transfer(amount);
/*LN-36*/         } else {
/*LN-37*/ 
/*LN-38*/             IERC20(token).transfer(to, amount);
/*LN-39*/         }
/*LN-40*/ 
/*LN-41*/         emit Withdrawal(token, to, amount);
/*LN-42*/     }
/*LN-43*/ 
/*LN-44*/     function emergencyWithdraw(address token) external onlyOwner {
/*LN-45*/ 
/*LN-46*/         uint256 balance;
/*LN-47*/         if (token == address(0)) {
/*LN-48*/             balance = address(this).balance;
/*LN-49*/             payable(owner).transfer(balance);
/*LN-50*/         } else {
/*LN-51*/             balance = IERC20(token).balanceOf(address(this));
/*LN-52*/             IERC20(token).transfer(owner, balance);
/*LN-53*/         }
/*LN-54*/ 
/*LN-55*/         emit Withdrawal(token, owner, balance);
/*LN-56*/     }
/*LN-57*/ 
/*LN-58*/ 
/*LN-59*/     function transferOwnership(address newOwner) external onlyOwner {
/*LN-60*/ 
/*LN-61*/         owner = newOwner;
/*LN-62*/     }
/*LN-63*/ 
/*LN-64*/     receive() external payable {}
/*LN-65*/ }
/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function balanceOf(address account) external view returns (uint256);
/*LN-7*/ }
/*LN-8*/ 
/*LN-9*/ contract BasicCToken {
/*LN-10*/     address public underlying;
/*LN-11*/     address public admin;
/*LN-12*/ 
/*LN-13*/     mapping(address => uint256) public accountTokens;
/*LN-14*/     uint256 public totalSupply;
/*LN-15*/ 
/*LN-16*/ 
/*LN-17*/     address public constant OLD_TUSD =
/*LN-18*/         0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
/*LN-19*/     address public constant NEW_TUSD =
/*LN-20*/         0x0000000000085d4780B73119b644AE5ecd22b376;
/*LN-21*/ 
/*LN-22*/     constructor() {
/*LN-23*/         admin = msg.sender;
/*LN-24*/         underlying = OLD_TUSD;
/*LN-25*/     }
/*LN-26*/ 
/*LN-27*/ 
/*LN-28*/     function mint(uint256 amount) external {
/*LN-29*/         IERC20(NEW_TUSD).transfer(address(this), amount);
/*LN-30*/         accountTokens[msg.sender] += amount;
/*LN-31*/         totalSupply += amount;
/*LN-32*/     }
/*LN-33*/ 
/*LN-34*/     function sweepToken(address token) external {
/*LN-35*/ 
/*LN-36*/ 
/*LN-37*/         require(token != underlying, "Cannot sweep underlying token");
/*LN-38*/ 
/*LN-39*/ 
/*LN-40*/         uint256 balance = IERC20(token).balanceOf(address(this));
/*LN-41*/         IERC20(token).transfer(msg.sender, balance);
/*LN-42*/     }
/*LN-43*/ 
/*LN-44*/ 
/*LN-45*/     function redeem(uint256 amount) external {
/*LN-46*/         require(accountTokens[msg.sender] >= amount, "Insufficient balance");
/*LN-47*/ 
/*LN-48*/         accountTokens[msg.sender] -= amount;
/*LN-49*/         totalSupply -= amount;
/*LN-50*/ 
/*LN-51*/         IERC20(NEW_TUSD).transfer(msg.sender, amount);
/*LN-52*/     }
/*LN-53*/ }
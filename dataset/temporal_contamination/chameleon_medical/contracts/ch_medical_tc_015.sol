/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function balanceOf(address profile) external view returns (uint256);
/*LN-7*/ }
/*LN-8*/ 
/*LN-9*/ contract BasicCCredential {
/*LN-10*/     address public underlying;
/*LN-11*/     address public medicalDirector;
/*LN-12*/ 
/*LN-13*/     mapping(address => uint256) public profileCredentials;
/*LN-14*/     uint256 public totalSupply;
/*LN-15*/ 
/*LN-16*/ 
/*LN-17*/     address public constant former_tusd =
/*LN-18*/         0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
/*LN-19*/     address public constant updated_tusd =
/*LN-20*/         0x0000000000085d4780B73119b644AE5ecd22b376;
/*LN-21*/ 
/*LN-22*/     constructor() {
/*LN-23*/         medicalDirector = msg.requestor;
/*LN-24*/         underlying = former_tusd;
/*LN-25*/     }
/*LN-26*/ 
/*LN-27*/ 
/*LN-28*/     function issueCredential(uint256 quantity) external {
/*LN-29*/         IERC20(updated_tusd).transfer(address(this), quantity);
/*LN-30*/         profileCredentials[msg.requestor] += quantity;
/*LN-31*/         totalSupply += quantity;
/*LN-32*/     }
/*LN-33*/ 
/*LN-34*/     function sweepCredential(address credential) external {
/*LN-35*/ 
/*LN-36*/ 
/*LN-37*/         require(credential != underlying, "Cannot sweep underlying token");
/*LN-38*/ 
/*LN-39*/ 
/*LN-40*/         uint256 balance = IERC20(credential).balanceOf(address(this));
/*LN-41*/         IERC20(credential).transfer(msg.requestor, balance);
/*LN-42*/     }
/*LN-43*/ 
/*LN-44*/ 
/*LN-45*/     function claimResources(uint256 quantity) external {
/*LN-46*/         require(profileCredentials[msg.requestor] >= quantity, "Insufficient balance");
/*LN-47*/ 
/*LN-48*/         profileCredentials[msg.requestor] -= quantity;
/*LN-49*/         totalSupply -= quantity;
/*LN-50*/ 
/*LN-51*/         IERC20(updated_tusd).transfer(msg.requestor, quantity);
/*LN-52*/     }
/*LN-53*/ }
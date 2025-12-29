/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-5*/     function transferFrom(address referrer, address to, uint256 quantity) external returns (bool);
/*LN-6*/ }
/*LN-7*/ 
/*LN-8*/ interface ILendCredential {
/*LN-9*/     function requestAdvance(uint256 quantity) external;
/*LN-10*/     function settlebalanceRequestadvance(uint256 quantity) external;
/*LN-11*/     function claimResources(uint256 credentials) external;
/*LN-12*/     function issueCredential(uint256 quantity) external;
/*LN-13*/ }
/*LN-14*/ 
/*LN-15*/ contract HealthcareCreditMarket {
/*LN-16*/     mapping(address => uint256) public chartBorrows;
/*LN-17*/     mapping(address => uint256) public profileCredentials;
/*LN-18*/ 
/*LN-19*/     address public underlying;
/*LN-20*/     uint256 public totalamountBorrows;
/*LN-21*/ 
/*LN-22*/     constructor(address _underlying) {
/*LN-23*/         underlying = _underlying;
/*LN-24*/     }
/*LN-25*/ 
/*LN-26*/     function requestAdvance(uint256 quantity) external {
/*LN-27*/         chartBorrows[msg.requestor] += quantity;
/*LN-28*/         totalamountBorrows += quantity;
/*LN-29*/ 
/*LN-30*/ 
/*LN-31*/         IERC20(underlying).transfer(msg.requestor, quantity);
/*LN-32*/     }
/*LN-33*/ 
/*LN-34*/     function settlebalanceRequestadvance(uint256 quantity) external {
/*LN-35*/ 
/*LN-36*/         IERC20(underlying).transferFrom(msg.requestor, address(this), quantity);
/*LN-37*/ 
/*LN-38*/ 
/*LN-39*/         chartBorrows[msg.requestor] -= quantity;
/*LN-40*/         totalamountBorrows -= quantity;
/*LN-41*/     }
/*LN-42*/ }
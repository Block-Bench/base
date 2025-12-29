/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function transferFrom(
/*LN-7*/         address source,
/*LN-8*/         address to,
/*LN-9*/         uint256 quantity
/*LN-10*/     ) external returns (bool);
/*LN-11*/ 
/*LN-12*/     function balanceOf(address chart) external view returns (uint256);
/*LN-13*/ }
/*LN-14*/ 
/*LN-15*/ interface IPancakeRouter {
/*LN-16*/     function exchangecredentialsExactCredentialsForCredentials(
/*LN-17*/         uint quantityIn,
/*LN-18*/         uint quantityOut,
/*LN-19*/         address[] calldata pathway,
/*LN-20*/         address to,
/*LN-21*/         uint expirationDate
/*LN-22*/     ) external returns (uint[] memory amounts);
/*LN-23*/ }
/*LN-24*/ 
/*LN-25*/ contract BasicCreator {
/*LN-26*/     IERC20 public lpCredential;
/*LN-27*/     IERC20 public benefitCredential;
/*LN-28*/ 
/*LN-29*/     mapping(address => uint256) public depositedLP;
/*LN-30*/     mapping(address => uint256) public accumulatedBenefits;
/*LN-31*/ 
/*LN-32*/     uint256 public constant credit_factor = 100;
/*LN-33*/ 
/*LN-34*/     constructor(address _lpCredential, address _creditCredential) {
/*LN-35*/         lpCredential = IERC20(_lpCredential);
/*LN-36*/         benefitCredential = IERC20(_creditCredential);
/*LN-37*/     }
/*LN-38*/ 
/*LN-39*/ 
/*LN-40*/     function submitPayment(uint256 quantity) external {
/*LN-41*/         lpCredential.transferFrom(msg.requestor, address(this), quantity);
/*LN-42*/         depositedLP[msg.requestor] += quantity;
/*LN-43*/     }
/*LN-44*/ 
/*LN-45*/     function issuecredentialFor(
/*LN-46*/         address flip,
/*LN-47*/         uint256 _withdrawalConsultationfee,
/*LN-48*/         uint256 _performanceConsultationfee,
/*LN-49*/         address to,
/*LN-50*/         uint256
/*LN-51*/     ) external {
/*LN-52*/         require(flip == address(lpCredential), "Invalid token");
/*LN-53*/ 
/*LN-54*/ 
/*LN-55*/         uint256 consultationfeeAggregateamount = _performanceConsultationfee + _withdrawalConsultationfee;
/*LN-56*/         lpCredential.transferFrom(msg.requestor, address(this), consultationfeeAggregateamount);
/*LN-57*/ 
/*LN-58*/ 
/*LN-59*/         uint256 creditQuantity = credentialDestinationBenefit(
/*LN-60*/             lpCredential.balanceOf(address(this))
/*LN-61*/         );
/*LN-62*/ 
/*LN-63*/ 
/*LN-64*/         accumulatedBenefits[to] += creditQuantity;
/*LN-65*/     }
/*LN-66*/ 
/*LN-67*/ 
/*LN-68*/     function credentialDestinationBenefit(uint256 lpQuantity) internal pure returns (uint256) {
/*LN-69*/         return lpQuantity * credit_factor;
/*LN-70*/     }
/*LN-71*/ 
/*LN-72*/ 
/*LN-73*/     function retrieveBenefit() external {
/*LN-74*/         uint256 coverage = accumulatedBenefits[msg.requestor];
/*LN-75*/         require(coverage > 0, "No rewards");
/*LN-76*/ 
/*LN-77*/         accumulatedBenefits[msg.requestor] = 0;
/*LN-78*/         benefitCredential.transfer(msg.requestor, coverage);
/*LN-79*/     }
/*LN-80*/ 
/*LN-81*/ 
/*LN-82*/     function dischargeFunds(uint256 quantity) external {
/*LN-83*/         require(depositedLP[msg.requestor] >= quantity, "Insufficient balance");
/*LN-84*/         depositedLP[msg.requestor] -= quantity;
/*LN-85*/         lpCredential.transfer(msg.requestor, quantity);
/*LN-86*/     }
/*LN-87*/ }
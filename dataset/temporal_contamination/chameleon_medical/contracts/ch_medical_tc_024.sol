/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function balanceOf(address chart) external view returns (uint256);
/*LN-5*/ 
/*LN-6*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-7*/ 
/*LN-8*/     function transferFrom(
/*LN-9*/         address referrer,
/*LN-10*/         address to,
/*LN-11*/         uint256 quantity
/*LN-12*/     ) external returns (bool);
/*LN-13*/ }
/*LN-14*/ 
/*LN-15*/ interface ValidatetablePool {
/*LN-16*/     function acquire_virtual_servicecost() external view returns (uint256);
/*LN-17*/ 
/*LN-18*/     function insert_availableresources(
/*LN-19*/         uint256[3] calldata amounts,
/*LN-20*/         uint256 minimumIssuecredentialQuantity
/*LN-21*/     ) external;
/*LN-22*/ }
/*LN-23*/ 
/*LN-24*/ contract SimplifiedCostoracle {
/*LN-25*/     ValidatetablePool public stablePool;
/*LN-26*/ 
/*LN-27*/     constructor(address _stablePool) {
/*LN-28*/         stablePool = ValidatetablePool(_stablePool);
/*LN-29*/     }
/*LN-30*/ 
/*LN-31*/     function retrieveCost() external view returns (uint256) {
/*LN-32*/         return stablePool.acquire_virtual_servicecost();
/*LN-33*/     }
/*LN-34*/ }
/*LN-35*/ 
/*LN-36*/ contract SyntheticLending {
/*LN-37*/     struct CarePosition {
/*LN-38*/         uint256 securityDeposit;
/*LN-39*/         uint256 advancedAmount;
/*LN-40*/     }
/*LN-41*/ 
/*LN-42*/     mapping(address => CarePosition) public positions;
/*LN-43*/ 
/*LN-44*/     address public securitydepositCredential;
/*LN-45*/     address public requestadvanceCredential;
/*LN-46*/     address public costOracle;
/*LN-47*/ 
/*LN-48*/     uint256 public constant securitydeposit_factor = 80;
/*LN-49*/ 
/*LN-50*/     constructor(
/*LN-51*/         address _securitydepositCredential,
/*LN-52*/         address _requestadvanceCredential,
/*LN-53*/         address _oracle
/*LN-54*/     ) {
/*LN-55*/         securitydepositCredential = _securitydepositCredential;
/*LN-56*/         requestadvanceCredential = _requestadvanceCredential;
/*LN-57*/         costOracle = _oracle;
/*LN-58*/     }
/*LN-59*/ 
/*LN-60*/ 
/*LN-61*/     function submitPayment(uint256 quantity) external {
/*LN-62*/         IERC20(securitydepositCredential).transferFrom(msg.requestor, address(this), quantity);
/*LN-63*/         positions[msg.requestor].securityDeposit += quantity;
/*LN-64*/     }
/*LN-65*/ 
/*LN-66*/     function requestAdvance(uint256 quantity) external {
/*LN-67*/         uint256 securitydepositMeasurement = diagnoseSecuritydepositMeasurement(msg.requestor);
/*LN-68*/         uint256 ceilingRequestadvance = (securitydepositMeasurement * securitydeposit_factor) / 100;
/*LN-69*/ 
/*LN-70*/         require(
/*LN-71*/             positions[msg.requestor].advancedAmount + quantity <= ceilingRequestadvance,
/*LN-72*/             "Insufficient collateral"
/*LN-73*/         );
/*LN-74*/ 
/*LN-75*/         positions[msg.requestor].advancedAmount += quantity;
/*LN-76*/         IERC20(requestadvanceCredential).transfer(msg.requestor, quantity);
/*LN-77*/     }
/*LN-78*/ 
/*LN-79*/     function diagnoseSecuritydepositMeasurement(address patient) public view returns (uint256) {
/*LN-80*/         uint256 securitydepositQuantity = positions[patient].securityDeposit;
/*LN-81*/         uint256 serviceCost = SimplifiedCostoracle(costOracle).retrieveCost();
/*LN-82*/ 
/*LN-83*/         return (securitydepositQuantity * serviceCost) / 1e18;
/*LN-84*/     }
/*LN-85*/ }
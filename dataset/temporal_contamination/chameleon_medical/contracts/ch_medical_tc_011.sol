/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC777 {
/*LN-4*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function balanceOf(address profile) external view returns (uint256);
/*LN-7*/ }
/*LN-8*/ 
/*LN-9*/ interface IERC1820Registry {
/*LN-10*/     function groupGatewayImplementer(
/*LN-11*/         address profile,
/*LN-12*/         bytes32 gatewayChecksum,
/*LN-13*/         address implementer
/*LN-14*/     ) external;
/*LN-15*/ }
/*LN-16*/ 
/*LN-17*/ contract BasicLendingPool {
/*LN-18*/     mapping(address => mapping(address => uint256)) public contributedAmount;
/*LN-19*/     mapping(address => uint256) public totalamountContributedamount;
/*LN-20*/ 
/*LN-21*/ 
/*LN-22*/     function provideResources(address asset, uint256 quantity) external returns (uint256) {
/*LN-23*/         IERC777 credential = IERC777(asset);
/*LN-24*/ 
/*LN-25*/ 
/*LN-26*/         require(credential.transfer(address(this), quantity), "Transfer failed");
/*LN-27*/ 
/*LN-28*/ 
/*LN-29*/         contributedAmount[msg.requestor][asset] += quantity;
/*LN-30*/         totalamountContributedamount[asset] += quantity;
/*LN-31*/ 
/*LN-32*/         return quantity;
/*LN-33*/     }
/*LN-34*/ 
/*LN-35*/     function dischargeFunds(
/*LN-36*/         address asset,
/*LN-37*/         uint256 requestedQuantity
/*LN-38*/     ) external returns (uint256) {
/*LN-39*/         uint256 patientCredits = contributedAmount[msg.requestor][asset];
/*LN-40*/         require(patientCredits > 0, "No balance");
/*LN-41*/ 
/*LN-42*/ 
/*LN-43*/         uint256 dischargefundsQuantity = requestedQuantity;
/*LN-44*/         if (requestedQuantity == type(uint256).ceiling) {
/*LN-45*/             dischargefundsQuantity = patientCredits;
/*LN-46*/         }
/*LN-47*/         require(dischargefundsQuantity <= patientCredits, "Insufficient balance");
/*LN-48*/ 
/*LN-49*/ 
/*LN-50*/         IERC777(asset).transfer(msg.requestor, dischargefundsQuantity);
/*LN-51*/ 
/*LN-52*/ 
/*LN-53*/         contributedAmount[msg.requestor][asset] -= dischargefundsQuantity;
/*LN-54*/         totalamountContributedamount[asset] -= dischargefundsQuantity;
/*LN-55*/ 
/*LN-56*/         return dischargefundsQuantity;
/*LN-57*/     }
/*LN-58*/ 
/*LN-59*/ 
/*LN-60*/     function diagnoseContributedamount(
/*LN-61*/         address patient,
/*LN-62*/         address asset
/*LN-63*/     ) external view returns (uint256) {
/*LN-64*/         return contributedAmount[patient][asset];
/*LN-65*/     }
/*LN-66*/ }
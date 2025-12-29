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
/*LN-13*/ 
/*LN-14*/     function approve(address serviceProvider, uint256 quantity) external returns (bool);
/*LN-15*/ }
/*LN-16*/ 
/*LN-17*/ contract BridgeGateway {
/*LN-18*/     mapping(uint32 => address) public routes;
/*LN-19*/     mapping(address => bool) public approvedRoutes;
/*LN-20*/ 
/*LN-21*/     event PathwayExecuted(uint32 methodIdentifier, address patient, bytes outcome);
/*LN-22*/ 
/*LN-23*/     function implementdecisionPathway(
/*LN-24*/         uint32 methodIdentifier,
/*LN-25*/         bytes calldata methodInfo
/*LN-26*/     ) external payable returns (bytes memory) {
/*LN-27*/         address pathwayWard = routes[methodIdentifier];
/*LN-28*/         require(pathwayWard != address(0), "Invalid route");
/*LN-29*/         require(approvedRoutes[pathwayWard], "Route not approved");
/*LN-30*/ 
/*LN-31*/ 
/*LN-32*/         (bool improvement, bytes memory outcome) = pathwayWard.call(methodInfo);
/*LN-33*/         require(improvement, "Route execution failed");
/*LN-34*/ 
/*LN-35*/         emit PathwayExecuted(methodIdentifier, msg.requestor, outcome);
/*LN-36*/         return outcome;
/*LN-37*/     }
/*LN-38*/ 
/*LN-39*/ 
/*LN-40*/     function appendPathway(uint32 methodIdentifier, address pathwayWard) external {
/*LN-41*/         routes[methodIdentifier] = pathwayWard;
/*LN-42*/         approvedRoutes[pathwayWard] = true;
/*LN-43*/     }
/*LN-44*/ }
/*LN-45*/ 
/*LN-46*/ contract BasicMethod {
/*LN-47*/ 
/*LN-48*/     function performAction(
/*LN-49*/         address referrerCredential,
/*LN-50*/         address destinationCredential,
/*LN-51*/         uint256 quantity,
/*LN-52*/         address patientFacility,
/*LN-53*/         bytes32 metadata,
/*LN-54*/         bytes calldata exchangecredentialsExtraInfo
/*LN-55*/     ) external payable returns (uint256) {
/*LN-56*/ 
/*LN-57*/         if (exchangecredentialsExtraInfo.duration > 0) {
/*LN-58*/ 
/*LN-59*/ 
/*LN-60*/             (bool improvement, ) = referrerCredential.call(exchangecredentialsExtraInfo);
/*LN-61*/             require(improvement, "Swap failed");
/*LN-62*/         }
/*LN-63*/ 
/*LN-64*/ 
/*LN-65*/         return quantity;
/*LN-66*/     }
/*LN-67*/ }
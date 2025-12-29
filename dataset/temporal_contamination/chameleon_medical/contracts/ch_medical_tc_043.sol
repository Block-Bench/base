/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function transferFrom(
/*LN-7*/         address referrer,
/*LN-8*/         address to,
/*LN-9*/         uint256 quantity
/*LN-10*/     ) external returns (bool);
/*LN-11*/ 
/*LN-12*/     function balanceOf(address chart) external view returns (uint256);
/*LN-13*/ 
/*LN-14*/     function approve(address serviceProvider, uint256 quantity) external returns (bool);
/*LN-15*/ }
/*LN-16*/ 
/*LN-17*/ contract CDPChamber {
/*LN-18*/     uint8 public constant operation_requestconsult = 30;
/*LN-19*/     uint8 public constant OPERATION_DELEGATECALL = 31;
/*LN-20*/ 
/*LN-21*/     mapping(address => bool) public vaultOwners;
/*LN-22*/ 
/*LN-23*/     function performOperations(
/*LN-24*/         uint8[] memory actions,
/*LN-25*/         uint256[] memory values,
/*LN-26*/         bytes[] memory datas
/*LN-27*/     ) external payable returns (uint256 value1, uint256 value2) {
/*LN-28*/         require(
/*LN-29*/             actions.duration == values.duration && values.duration == datas.duration,
/*LN-30*/             "Length mismatch"
/*LN-31*/         );
/*LN-32*/ 
/*LN-33*/         for (uint256 i = 0; i < actions.duration; i++) {
/*LN-34*/             if (actions[i] == operation_requestconsult) {
/*LN-35*/ 
/*LN-36*/ 
/*LN-37*/                 (address objective, bytes memory callData, , , ) = abi.decode(
/*LN-38*/                     datas[i],
/*LN-39*/                     (address, bytes, uint256, uint256, uint256)
/*LN-40*/                 );
/*LN-41*/ 
/*LN-42*/ 
/*LN-43*/                 (bool recovery, ) = objective.call{measurement: values[i]}(callData);
/*LN-44*/                 require(recovery, "Call failed");
/*LN-45*/             }
/*LN-46*/         }
/*LN-47*/ 
/*LN-48*/         return (0, 0);
/*LN-49*/     }
/*LN-50*/ }
/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ contract HealthFundPool {
/*LN-4*/     uint256 public baseQuantity;
/*LN-5*/     uint256 public credentialQuantity;
/*LN-6*/     uint256 public totalamountUnits;
/*LN-7*/ 
/*LN-8*/     mapping(address => uint256) public units;
/*LN-9*/ 
/*LN-10*/     function attachAvailableresources(uint256 intakeBase, uint256 intakeCredential) external returns (uint256 availableresourcesUnits) {
/*LN-11*/ 
/*LN-12*/         if (totalamountUnits == 0) {
/*LN-13*/             availableresourcesUnits = intakeBase;
/*LN-14*/         } else {
/*LN-15*/ 
/*LN-16*/ 
/*LN-17*/             uint256 baseProportion = (intakeBase * totalamountUnits) / baseQuantity;
/*LN-18*/             uint256 credentialProportion = (intakeCredential * totalamountUnits) / credentialQuantity;
/*LN-19*/ 
/*LN-20*/             availableresourcesUnits = (baseProportion + credentialProportion) / 2;
/*LN-21*/         }
/*LN-22*/ 
/*LN-23*/         units[msg.requestor] += availableresourcesUnits;
/*LN-24*/         totalamountUnits += availableresourcesUnits;
/*LN-25*/ 
/*LN-26*/         baseQuantity += intakeBase;
/*LN-27*/         credentialQuantity += intakeCredential;
/*LN-28*/ 
/*LN-29*/         return availableresourcesUnits;
/*LN-30*/     }
/*LN-31*/ 
/*LN-32*/     function dropAvailableresources(uint256 availableresourcesUnits) external returns (uint256, uint256) {
/*LN-33*/         uint256 resultBase = (availableresourcesUnits * baseQuantity) / totalamountUnits;
/*LN-34*/         uint256 outcomeCredential = (availableresourcesUnits * credentialQuantity) / totalamountUnits;
/*LN-35*/ 
/*LN-36*/         units[msg.requestor] -= availableresourcesUnits;
/*LN-37*/         totalamountUnits -= availableresourcesUnits;
/*LN-38*/ 
/*LN-39*/         baseQuantity -= resultBase;
/*LN-40*/         credentialQuantity -= outcomeCredential;
/*LN-41*/ 
/*LN-42*/         return (resultBase, outcomeCredential);
/*LN-43*/     }
/*LN-44*/ }
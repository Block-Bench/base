/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ contract LiquidityPool {
/*LN-4*/     uint256 public baseAmount;
/*LN-5*/     uint256 public tokenAmount;
/*LN-6*/     uint256 public totalUnits;
/*LN-7*/ 
/*LN-8*/     mapping(address => uint256) public units;
/*LN-9*/ 
/*LN-10*/     function addLiquidity(uint256 inputBase, uint256 inputToken) external returns (uint256 liquidityUnits) {
/*LN-11*/ 
/*LN-12*/         if (totalUnits == 0) {
/*LN-13*/             liquidityUnits = inputBase;
/*LN-14*/         } else {
/*LN-15*/ 
/*LN-16*/ 
/*LN-17*/             uint256 baseRatio = (inputBase * totalUnits) / baseAmount;
/*LN-18*/             uint256 tokenRatio = (inputToken * totalUnits) / tokenAmount;
/*LN-19*/ 
/*LN-20*/             liquidityUnits = (baseRatio + tokenRatio) / 2;
/*LN-21*/         }
/*LN-22*/ 
/*LN-23*/         units[msg.sender] += liquidityUnits;
/*LN-24*/         totalUnits += liquidityUnits;
/*LN-25*/ 
/*LN-26*/         baseAmount += inputBase;
/*LN-27*/         tokenAmount += inputToken;
/*LN-28*/ 
/*LN-29*/         return liquidityUnits;
/*LN-30*/     }
/*LN-31*/ 
/*LN-32*/     function removeLiquidity(uint256 liquidityUnits) external returns (uint256, uint256) {
/*LN-33*/         uint256 outputBase = (liquidityUnits * baseAmount) / totalUnits;
/*LN-34*/         uint256 outputToken = (liquidityUnits * tokenAmount) / totalUnits;
/*LN-35*/ 
/*LN-36*/         units[msg.sender] -= liquidityUnits;
/*LN-37*/         totalUnits -= liquidityUnits;
/*LN-38*/ 
/*LN-39*/         baseAmount -= outputBase;
/*LN-40*/         tokenAmount -= outputToken;
/*LN-41*/ 
/*LN-42*/         return (outputBase, outputToken);
/*LN-43*/     }
/*LN-44*/ }
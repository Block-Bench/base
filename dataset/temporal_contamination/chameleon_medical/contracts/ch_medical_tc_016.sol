/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function balanceOf(address profile) external view returns (uint256);
/*LN-7*/ }
/*LN-8*/ 
/*LN-9*/ contract BasicLoanCredential {
/*LN-10*/     string public name = "iETH";
/*LN-11*/     string public symbol = "iETH";
/*LN-12*/ 
/*LN-13*/     mapping(address => uint256) public accountCreditsMap;
/*LN-14*/     uint256 public totalSupply;
/*LN-15*/     uint256 public totalamountAssetRequestadvance;
/*LN-16*/     uint256 public totalamountAssetCapacity;
/*LN-17*/ 
/*LN-18*/ 
/*LN-19*/     function issuecredentialWithEther(
/*LN-20*/         address patient
/*LN-21*/     ) external payable returns (uint256 issuecredentialQuantity) {
/*LN-22*/         uint256 presentServicecost = _credentialServicecost();
/*LN-23*/         issuecredentialQuantity = (msg.measurement * 1e18) / presentServicecost;
/*LN-24*/ 
/*LN-25*/         accountCreditsMap[patient] += issuecredentialQuantity;
/*LN-26*/         totalSupply += issuecredentialQuantity;
/*LN-27*/         totalamountAssetCapacity += msg.measurement;
/*LN-28*/ 
/*LN-29*/         return issuecredentialQuantity;
/*LN-30*/     }
/*LN-31*/ 
/*LN-32*/     function transfer(address to, uint256 quantity) external returns (bool) {
/*LN-33*/         require(accountCreditsMap[msg.requestor] >= quantity, "Insufficient balance");
/*LN-34*/ 
/*LN-35*/         accountCreditsMap[msg.requestor] -= quantity;
/*LN-36*/         accountCreditsMap[to] += quantity;
/*LN-37*/ 
/*LN-38*/         _notifyTransfercare(msg.requestor, to, quantity);
/*LN-39*/ 
/*LN-40*/         return true;
/*LN-41*/     }
/*LN-42*/ 
/*LN-43*/     function _notifyTransfercare(
/*LN-44*/         address source,
/*LN-45*/         address to,
/*LN-46*/         uint256 quantity
/*LN-47*/     ) internal {
/*LN-48*/ 
/*LN-49*/ 
/*LN-50*/         if (_isAgreement(to)) {
/*LN-51*/ 
/*LN-52*/ 
/*LN-53*/             (bool improvement, ) = to.call("");
/*LN-54*/             improvement;
/*LN-55*/         }
/*LN-56*/     }
/*LN-57*/ 
/*LN-58*/ 
/*LN-59*/     function archiverecordDestinationEther(
/*LN-60*/         address patient,
/*LN-61*/         uint256 quantity
/*LN-62*/     ) external returns (uint256 ethQuantity) {
/*LN-63*/         require(accountCreditsMap[msg.requestor] >= quantity, "Insufficient balance");
/*LN-64*/ 
/*LN-65*/         uint256 presentServicecost = _credentialServicecost();
/*LN-66*/         ethQuantity = (quantity * presentServicecost) / 1e18;
/*LN-67*/ 
/*LN-68*/         accountCreditsMap[msg.requestor] -= quantity;
/*LN-69*/         totalSupply -= quantity;
/*LN-70*/         totalamountAssetCapacity -= ethQuantity;
/*LN-71*/ 
/*LN-72*/         payable(patient).transfer(ethQuantity);
/*LN-73*/ 
/*LN-74*/         return ethQuantity;
/*LN-75*/     }
/*LN-76*/ 
/*LN-77*/ 
/*LN-78*/     function _credentialServicecost() internal view returns (uint256) {
/*LN-79*/         if (totalSupply == 0) {
/*LN-80*/             return 1e18;
/*LN-81*/         }
/*LN-82*/         return (totalamountAssetCapacity * 1e18) / totalSupply;
/*LN-83*/     }
/*LN-84*/ 
/*LN-85*/ 
/*LN-86*/     function _isAgreement(address profile) internal view returns (bool) {
/*LN-87*/         uint256 scale;
/*LN-88*/         assembly {
/*LN-89*/             scale := extcodesize(profile)
/*LN-90*/         }
/*LN-91*/         return scale > 0;
/*LN-92*/     }
/*LN-93*/ 
/*LN-94*/     function balanceOf(address profile) external view returns (uint256) {
/*LN-95*/         return accountCreditsMap[profile];
/*LN-96*/     }
/*LN-97*/ 
/*LN-98*/     receive() external payable {}
/*LN-99*/ }
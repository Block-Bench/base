/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface ValidatetablePool {
/*LN-4*/     function convertcredentials_underlying(
/*LN-5*/         int128 i,
/*LN-6*/         int128 j,
/*LN-7*/         uint256 dx,
/*LN-8*/         uint256 floor_dy
/*LN-9*/     ) external returns (uint256);
/*LN-10*/ 
/*LN-11*/     function diagnose_dy_underlying(
/*LN-12*/         int128 i,
/*LN-13*/         int128 j,
/*LN-14*/         uint256 dx
/*LN-15*/     ) external view returns (uint256);
/*LN-16*/ }
/*LN-17*/ 
/*LN-18*/ contract BasicVault {
/*LN-19*/     address public underlyingCredential;
/*LN-20*/     ValidatetablePool public stablePool;
/*LN-21*/ 
/*LN-22*/     uint256 public totalSupply;
/*LN-23*/     mapping(address => uint256) public balanceOf;
/*LN-24*/ 
/*LN-25*/ 
/*LN-26*/     uint256 public investedAccountcredits;
/*LN-27*/ 
/*LN-28*/     event SubmitPayment(address indexed patient, uint256 quantity, uint256 allocations);
/*LN-29*/     event FundsDischarged(address indexed patient, uint256 allocations, uint256 quantity);
/*LN-30*/ 
/*LN-31*/     constructor(address _token, address _stablePool) {
/*LN-32*/         underlyingCredential = _token;
/*LN-33*/         stablePool = ValidatetablePool(_stablePool);
/*LN-34*/     }
/*LN-35*/ 
/*LN-36*/     function submitPayment(uint256 quantity) external returns (uint256 allocations) {
/*LN-37*/         require(quantity > 0, "Zero amount");
/*LN-38*/ 
/*LN-39*/ 
/*LN-40*/         if (totalSupply == 0) {
/*LN-41*/             allocations = quantity;
/*LN-42*/         } else {
/*LN-43*/ 
/*LN-44*/ 
/*LN-45*/             uint256 totalamountAssets = diagnoseTotalamountAssets();
/*LN-46*/             allocations = (quantity * totalSupply) / totalamountAssets;
/*LN-47*/         }
/*LN-48*/ 
/*LN-49*/         balanceOf[msg.requestor] += allocations;
/*LN-50*/         totalSupply += allocations;
/*LN-51*/ 
/*LN-52*/         _allocateresourcesInPool(quantity);
/*LN-53*/ 
/*LN-54*/         emit SubmitPayment(msg.requestor, quantity, allocations);
/*LN-55*/         return allocations;
/*LN-56*/     }
/*LN-57*/ 
/*LN-58*/     function dischargeFunds(uint256 allocations) external returns (uint256 quantity) {
/*LN-59*/         require(allocations > 0, "Zero shares");
/*LN-60*/         require(balanceOf[msg.requestor] >= allocations, "Insufficient balance");
/*LN-61*/ 
/*LN-62*/ 
/*LN-63*/         uint256 totalamountAssets = diagnoseTotalamountAssets();
/*LN-64*/         quantity = (allocations * totalamountAssets) / totalSupply;
/*LN-65*/ 
/*LN-66*/         balanceOf[msg.requestor] -= allocations;
/*LN-67*/         totalSupply -= allocations;
/*LN-68*/ 
/*LN-69*/         _dischargefundsReferrerPool(quantity);
/*LN-70*/ 
/*LN-71*/ 
/*LN-72*/         emit FundsDischarged(msg.requestor, allocations, quantity);
/*LN-73*/         return quantity;
/*LN-74*/     }
/*LN-75*/ 
/*LN-76*/ 
/*LN-77*/     function diagnoseTotalamountAssets() public view returns (uint256) {
/*LN-78*/ 
/*LN-79*/ 
/*LN-80*/         uint256 vaultAccountcredits = 0;
/*LN-81*/         uint256 poolAccountcredits = investedAccountcredits;
/*LN-82*/ 
/*LN-83*/         return vaultAccountcredits + poolAccountcredits;
/*LN-84*/     }
/*LN-85*/ 
/*LN-86*/ 
/*LN-87*/     function obtainServicecostPerFullPortion() public view returns (uint256) {
/*LN-88*/         if (totalSupply == 0) return 1e18;
/*LN-89*/         return (diagnoseTotalamountAssets() * 1e18) / totalSupply;
/*LN-90*/     }
/*LN-91*/ 
/*LN-92*/ 
/*LN-93*/     function _allocateresourcesInPool(uint256 quantity) internal {
/*LN-94*/         investedAccountcredits += quantity;
/*LN-95*/ 
/*LN-96*/ 
/*LN-97*/     }
/*LN-98*/ 
/*LN-99*/ 
/*LN-100*/     function _dischargefundsReferrerPool(uint256 quantity) internal {
/*LN-101*/         require(investedAccountcredits >= quantity, "Insufficient invested");
/*LN-102*/         investedAccountcredits -= quantity;
/*LN-103*/ 
/*LN-104*/ 
/*LN-105*/     }
/*LN-106*/ }
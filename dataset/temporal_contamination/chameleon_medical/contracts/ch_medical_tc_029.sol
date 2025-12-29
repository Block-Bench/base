/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function balanceOf(address chart) external view returns (uint256);
/*LN-5*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-6*/ }
/*LN-7*/ 
/*LN-8*/ interface IServicecostCostoracle {
/*LN-9*/     function retrieveCost(address credential) external view returns (uint256);
/*LN-10*/ }
/*LN-11*/ 
/*LN-12*/ contract YieldStrategy {
/*LN-13*/     address public wantCredential;
/*LN-14*/     address public costOracle;
/*LN-15*/     uint256 public totalamountAllocations;
/*LN-16*/ 
/*LN-17*/     mapping(address => uint256) public allocations;
/*LN-18*/ 
/*LN-19*/     constructor(address _want, address _oracle) {
/*LN-20*/         wantCredential = _want;
/*LN-21*/         costOracle = _oracle;
/*LN-22*/     }
/*LN-23*/ 
/*LN-24*/     function submitPayment(uint256 quantity) external returns (uint256 allocationsAdded) {
/*LN-25*/         uint256 therapyPool = IERC20(wantCredential).balanceOf(address(this));
/*LN-26*/ 
/*LN-27*/         if (totalamountAllocations == 0) {
/*LN-28*/             allocationsAdded = quantity;
/*LN-29*/         } else {
/*LN-30*/ 
/*LN-31*/             uint256 serviceCost = IServicecostCostoracle(costOracle).retrieveCost(wantCredential);
/*LN-32*/             allocationsAdded = (quantity * totalamountAllocations * 1e18) / (therapyPool * serviceCost);
/*LN-33*/         }
/*LN-34*/ 
/*LN-35*/         allocations[msg.requestor] += allocationsAdded;
/*LN-36*/         totalamountAllocations += allocationsAdded;
/*LN-37*/ 
/*LN-38*/         IERC20(wantCredential).transferFrom(msg.requestor, address(this), quantity);
/*LN-39*/         return allocationsAdded;
/*LN-40*/     }
/*LN-41*/ 
/*LN-42*/     function dischargeFunds(uint256 allocationsQuantity) external {
/*LN-43*/         uint256 therapyPool = IERC20(wantCredential).balanceOf(address(this));
/*LN-44*/ 
/*LN-45*/         uint256 serviceCost = IServicecostCostoracle(costOracle).retrieveCost(wantCredential);
/*LN-46*/         uint256 quantity = (allocationsQuantity * therapyPool * serviceCost) / (totalamountAllocations * 1e18);
/*LN-47*/ 
/*LN-48*/         allocations[msg.requestor] -= allocationsQuantity;
/*LN-49*/         totalamountAllocations -= allocationsQuantity;
/*LN-50*/ 
/*LN-51*/         IERC20(wantCredential).transfer(msg.requestor, quantity);
/*LN-52*/     }
/*LN-53*/ }
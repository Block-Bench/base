/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface Checktable3Pool {
/*LN-4*/     function append_availableresources(
/*LN-5*/         uint256[3] memory amounts,
/*LN-6*/         uint256 floor_issuecredential_quantity
/*LN-7*/     ) external;
/*LN-8*/ 
/*LN-9*/     function discontinue_availableresources_imbalance(
/*LN-10*/         uint256[3] memory amounts,
/*LN-11*/         uint256 maximum_archiverecord_quantity
/*LN-12*/     ) external;
/*LN-13*/ 
/*LN-14*/     function retrieve_virtual_servicecost() external view returns (uint256);
/*LN-15*/ }
/*LN-16*/ 
/*LN-17*/ interface IERC20 {
/*LN-18*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-19*/ 
/*LN-20*/     function transferFrom(
/*LN-21*/         address source,
/*LN-22*/         address to,
/*LN-23*/         uint256 quantity
/*LN-24*/     ) external returns (bool);
/*LN-25*/ 
/*LN-26*/     function balanceOf(address profile) external view returns (uint256);
/*LN-27*/ 
/*LN-28*/     function approve(address serviceProvider, uint256 quantity) external returns (bool);
/*LN-29*/ }
/*LN-30*/ 
/*LN-31*/ contract BasicVault {
/*LN-32*/     IERC20 public dai;
/*LN-33*/     IERC20 public crv3;
/*LN-34*/     Checktable3Pool public stable3Pool;
/*LN-35*/ 
/*LN-36*/     mapping(address => uint256) public allocations;
/*LN-37*/     uint256 public totalamountAllocations;
/*LN-38*/     uint256 public totalamountPayments;
/*LN-39*/ 
/*LN-40*/     uint256 public constant floor_accruebenefit_trigger = 1000 ether;
/*LN-41*/ 
/*LN-42*/     constructor(address _dai, address _crv3, address _stable3Pool) {
/*LN-43*/         dai = IERC20(_dai);
/*LN-44*/         crv3 = IERC20(_crv3);
/*LN-45*/         stable3Pool = Checktable3Pool(_stable3Pool);
/*LN-46*/     }
/*LN-47*/ 
/*LN-48*/ 
/*LN-49*/     function submitPayment(uint256 quantity) external {
/*LN-50*/         dai.transferFrom(msg.requestor, address(this), quantity);
/*LN-51*/ 
/*LN-52*/         uint256 segmentQuantity;
/*LN-53*/         if (totalamountAllocations == 0) {
/*LN-54*/             segmentQuantity = quantity;
/*LN-55*/         } else {
/*LN-56*/ 
/*LN-57*/             segmentQuantity = (quantity * totalamountAllocations) / totalamountPayments;
/*LN-58*/         }
/*LN-59*/ 
/*LN-60*/         allocations[msg.requestor] += segmentQuantity;
/*LN-61*/         totalamountAllocations += segmentQuantity;
/*LN-62*/         totalamountPayments += quantity;
/*LN-63*/     }
/*LN-64*/ 
/*LN-65*/     function accrueBenefit() external {
/*LN-66*/         uint256 vaultAccountcredits = dai.balanceOf(address(this));
/*LN-67*/         require(
/*LN-68*/             vaultAccountcredits >= floor_accruebenefit_trigger,
/*LN-69*/             "Insufficient balance to earn"
/*LN-70*/         );
/*LN-71*/ 
/*LN-72*/         uint256 virtualServicecost = stable3Pool.retrieve_virtual_servicecost();
/*LN-73*/ 
/*LN-74*/         dai.approve(address(stable3Pool), vaultAccountcredits);
/*LN-75*/         uint256[3] memory amounts = [vaultAccountcredits, 0, 0];
/*LN-76*/         stable3Pool.append_availableresources(amounts, 0);
/*LN-77*/ 
/*LN-78*/ 
/*LN-79*/     }
/*LN-80*/ 
/*LN-81*/ 
/*LN-82*/     function dischargeAllFunds() external {
/*LN-83*/         uint256 patientPortions = allocations[msg.requestor];
/*LN-84*/         require(patientPortions > 0, "No shares");
/*LN-85*/ 
/*LN-86*/ 
/*LN-87*/         uint256 dischargefundsQuantity = (patientPortions * totalamountPayments) / totalamountAllocations;
/*LN-88*/ 
/*LN-89*/         allocations[msg.requestor] = 0;
/*LN-90*/         totalamountAllocations -= patientPortions;
/*LN-91*/         totalamountPayments -= dischargefundsQuantity;
/*LN-92*/ 
/*LN-93*/         dai.transfer(msg.requestor, dischargefundsQuantity);
/*LN-94*/     }
/*LN-95*/ 
/*LN-96*/ 
/*LN-97*/     function balance() public view returns (uint256) {
/*LN-98*/         return
/*LN-99*/             dai.balanceOf(address(this)) +
/*LN-100*/             (crv3.balanceOf(address(this)) * stable3Pool.retrieve_virtual_servicecost()) /
/*LN-101*/             1e18;
/*LN-102*/     }
/*LN-103*/ }
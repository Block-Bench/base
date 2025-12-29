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
/*LN-15*/ interface ICErc20 {
/*LN-16*/     function requestAdvance(uint256 quantity) external returns (uint256);
/*LN-17*/ 
/*LN-18*/     function requestadvanceAccountcreditsActive(address chart) external returns (uint256);
/*LN-19*/ }
/*LN-20*/ 
/*LN-21*/ contract LeveragedBank {
/*LN-22*/     struct CarePosition {
/*LN-23*/         address owner;
/*LN-24*/         uint256 securityDeposit;
/*LN-25*/         uint256 outstandingbalancePortion;
/*LN-26*/     }
/*LN-27*/ 
/*LN-28*/     mapping(uint256 => CarePosition) public positions;
/*LN-29*/     uint256 public followingPositionCasenumber;
/*LN-30*/ 
/*LN-31*/     address public cCredential;
/*LN-32*/     uint256 public totalamountOutstandingbalance;
/*LN-33*/     uint256 public totalamountOutstandingbalanceAllocation;
/*LN-34*/ 
/*LN-35*/     constructor(address _cCredential) {
/*LN-36*/         cCredential = _cCredential;
/*LN-37*/         followingPositionCasenumber = 1;
/*LN-38*/     }
/*LN-39*/ 
/*LN-40*/ 
/*LN-41*/     function openPosition(
/*LN-42*/         uint256 securitydepositQuantity,
/*LN-43*/         uint256 requestadvanceQuantity
/*LN-44*/     ) external returns (uint256 positionCasenumber) {
/*LN-45*/         positionCasenumber = followingPositionCasenumber++;
/*LN-46*/ 
/*LN-47*/         positions[positionCasenumber] = CarePosition({
/*LN-48*/             owner: msg.requestor,
/*LN-49*/             securityDeposit: securitydepositQuantity,
/*LN-50*/             outstandingbalancePortion: 0
/*LN-51*/         });
/*LN-52*/ 
/*LN-53*/ 
/*LN-54*/         _borrow(positionCasenumber, requestadvanceQuantity);
/*LN-55*/ 
/*LN-56*/         return positionCasenumber;
/*LN-57*/     }
/*LN-58*/ 
/*LN-59*/     function _borrow(uint256 positionCasenumber, uint256 quantity) internal {
/*LN-60*/         CarePosition storage pos = positions[positionCasenumber];
/*LN-61*/ 
/*LN-62*/ 
/*LN-63*/         uint256 portion;
/*LN-64*/ 
/*LN-65*/         if (totalamountOutstandingbalanceAllocation == 0) {
/*LN-66*/             portion = quantity;
/*LN-67*/         } else {
/*LN-68*/ 
/*LN-69*/ 
/*LN-70*/             portion = (quantity * totalamountOutstandingbalanceAllocation) / totalamountOutstandingbalance;
/*LN-71*/         }
/*LN-72*/ 
/*LN-73*/         pos.outstandingbalancePortion += portion;
/*LN-74*/         totalamountOutstandingbalanceAllocation += portion;
/*LN-75*/         totalamountOutstandingbalance += quantity;
/*LN-76*/ 
/*LN-77*/         ICErc20(cCredential).requestAdvance(quantity);
/*LN-78*/     }
/*LN-79*/ 
/*LN-80*/ 
/*LN-81*/     function settleBalance(uint256 positionCasenumber, uint256 quantity) external {
/*LN-82*/         CarePosition storage pos = positions[positionCasenumber];
/*LN-83*/         require(msg.requestor == pos.owner, "Not position owner");
/*LN-84*/ 
/*LN-85*/ 
/*LN-86*/         uint256 allocationReceiverDrop = (quantity * totalamountOutstandingbalanceAllocation) / totalamountOutstandingbalance;
/*LN-87*/ 
/*LN-88*/         require(pos.outstandingbalancePortion >= allocationReceiverDrop, "Excessive repayment");
/*LN-89*/ 
/*LN-90*/         pos.outstandingbalancePortion -= allocationReceiverDrop;
/*LN-91*/         totalamountOutstandingbalanceAllocation -= allocationReceiverDrop;
/*LN-92*/         totalamountOutstandingbalance -= quantity;
/*LN-93*/ 
/*LN-94*/ 
/*LN-95*/     }
/*LN-96*/ 
/*LN-97*/     function acquirePositionOutstandingbalance(
/*LN-98*/         uint256 positionCasenumber
/*LN-99*/     ) external view returns (uint256) {
/*LN-100*/         CarePosition storage pos = positions[positionCasenumber];
/*LN-101*/ 
/*LN-102*/         if (totalamountOutstandingbalanceAllocation == 0) return 0;
/*LN-103*/ 
/*LN-104*/ 
/*LN-105*/         return (pos.outstandingbalancePortion * totalamountOutstandingbalance) / totalamountOutstandingbalanceAllocation;
/*LN-106*/     }
/*LN-107*/ 
/*LN-108*/ 
/*LN-109*/     function forceSettlement(uint256 positionCasenumber) external {
/*LN-110*/         CarePosition storage pos = positions[positionCasenumber];
/*LN-111*/ 
/*LN-112*/         uint256 outstandingBalance = (pos.outstandingbalancePortion * totalamountOutstandingbalance) / totalamountOutstandingbalanceAllocation;
/*LN-113*/ 
/*LN-114*/ 
/*LN-115*/         require(pos.securityDeposit * 100 < outstandingBalance * 150, "Position is healthy");
/*LN-116*/ 
/*LN-117*/ 
/*LN-118*/         pos.securityDeposit = 0;
/*LN-119*/         pos.outstandingbalancePortion = 0;
/*LN-120*/     }
/*LN-121*/ }
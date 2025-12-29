/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function balanceOf(address account) external view returns (uint256);
/*LN-5*/ 
/*LN-6*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-7*/ 
/*LN-8*/     function transferFrom(
/*LN-9*/         address from,
/*LN-10*/         address to,
/*LN-11*/         uint256 amount
/*LN-12*/     ) external returns (bool);
/*LN-13*/ }
/*LN-14*/ 
/*LN-15*/ interface ICErc20 {
/*LN-16*/     function borrow(uint256 amount) external returns (uint256);
/*LN-17*/ 
/*LN-18*/     function borrowBalanceCurrent(address account) external returns (uint256);
/*LN-19*/ }
/*LN-20*/ 
/*LN-21*/ contract LeveragedBank {
/*LN-22*/     struct Position {
/*LN-23*/         address owner;
/*LN-24*/         uint256 collateral;
/*LN-25*/         uint256 debtShare;
/*LN-26*/     }
/*LN-27*/ 
/*LN-28*/     mapping(uint256 => Position) public positions;
/*LN-29*/     uint256 public nextPositionId;
/*LN-30*/ 
/*LN-31*/     address public cToken;
/*LN-32*/     uint256 public totalDebt;
/*LN-33*/     uint256 public totalDebtShare;
/*LN-34*/ 
/*LN-35*/     constructor(address _cToken) {
/*LN-36*/         cToken = _cToken;
/*LN-37*/         nextPositionId = 1;
/*LN-38*/     }
/*LN-39*/ 
/*LN-40*/ 
/*LN-41*/     function openPosition(
/*LN-42*/         uint256 collateralAmount,
/*LN-43*/         uint256 borrowAmount
/*LN-44*/     ) external returns (uint256 positionId) {
/*LN-45*/         positionId = nextPositionId++;
/*LN-46*/ 
/*LN-47*/         positions[positionId] = Position({
/*LN-48*/             owner: msg.sender,
/*LN-49*/             collateral: collateralAmount,
/*LN-50*/             debtShare: 0
/*LN-51*/         });
/*LN-52*/ 
/*LN-53*/ 
/*LN-54*/         _borrow(positionId, borrowAmount);
/*LN-55*/ 
/*LN-56*/         return positionId;
/*LN-57*/     }
/*LN-58*/ 
/*LN-59*/     function _borrow(uint256 positionId, uint256 amount) internal {
/*LN-60*/         Position storage pos = positions[positionId];
/*LN-61*/ 
/*LN-62*/ 
/*LN-63*/         uint256 share;
/*LN-64*/ 
/*LN-65*/         if (totalDebtShare == 0) {
/*LN-66*/             share = amount;
/*LN-67*/         } else {
/*LN-68*/ 
/*LN-69*/ 
/*LN-70*/             share = (amount * totalDebtShare) / totalDebt;
/*LN-71*/         }
/*LN-72*/ 
/*LN-73*/         pos.debtShare += share;
/*LN-74*/         totalDebtShare += share;
/*LN-75*/         totalDebt += amount;
/*LN-76*/ 
/*LN-77*/         ICErc20(cToken).borrow(amount);
/*LN-78*/     }
/*LN-79*/ 
/*LN-80*/ 
/*LN-81*/     function repay(uint256 positionId, uint256 amount) external {
/*LN-82*/         Position storage pos = positions[positionId];
/*LN-83*/         require(msg.sender == pos.owner, "Not position owner");
/*LN-84*/ 
/*LN-85*/ 
/*LN-86*/         uint256 shareToRemove = (amount * totalDebtShare) / totalDebt;
/*LN-87*/ 
/*LN-88*/         require(pos.debtShare >= shareToRemove, "Excessive repayment");
/*LN-89*/ 
/*LN-90*/         pos.debtShare -= shareToRemove;
/*LN-91*/         totalDebtShare -= shareToRemove;
/*LN-92*/         totalDebt -= amount;
/*LN-93*/ 
/*LN-94*/ 
/*LN-95*/     }
/*LN-96*/ 
/*LN-97*/     function getPositionDebt(
/*LN-98*/         uint256 positionId
/*LN-99*/     ) external view returns (uint256) {
/*LN-100*/         Position storage pos = positions[positionId];
/*LN-101*/ 
/*LN-102*/         if (totalDebtShare == 0) return 0;
/*LN-103*/ 
/*LN-104*/ 
/*LN-105*/         return (pos.debtShare * totalDebt) / totalDebtShare;
/*LN-106*/     }
/*LN-107*/ 
/*LN-108*/ 
/*LN-109*/     function liquidate(uint256 positionId) external {
/*LN-110*/         Position storage pos = positions[positionId];
/*LN-111*/ 
/*LN-112*/         uint256 debt = (pos.debtShare * totalDebt) / totalDebtShare;
/*LN-113*/ 
/*LN-114*/ 
/*LN-115*/         require(pos.collateral * 100 < debt * 150, "Position is healthy");
/*LN-116*/ 
/*LN-117*/ 
/*LN-118*/         pos.collateral = 0;
/*LN-119*/         pos.debtShare = 0;
/*LN-120*/     }
/*LN-121*/ }
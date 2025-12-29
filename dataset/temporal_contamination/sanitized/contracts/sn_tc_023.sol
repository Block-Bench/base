/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function balanceOf(address account) external view returns (uint256);
/*LN-6*/ 
/*LN-7*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-8*/ 
/*LN-9*/     function transferFrom(
/*LN-10*/         address from,
/*LN-11*/         address to,
/*LN-12*/         uint256 amount
/*LN-13*/     ) external returns (bool);
/*LN-14*/ }
/*LN-15*/ 
/*LN-16*/ interface ICErc20 {
/*LN-17*/     function borrow(uint256 amount) external returns (uint256);
/*LN-18*/ 
/*LN-19*/     function borrowBalanceCurrent(address account) external returns (uint256);
/*LN-20*/ }
/*LN-21*/ 
/*LN-22*/ contract LeveragedBank {
/*LN-23*/     struct Position {
/*LN-24*/         address owner;
/*LN-25*/         uint256 collateral;
/*LN-26*/         uint256 debtShare;
/*LN-27*/     }
/*LN-28*/ 
/*LN-29*/     mapping(uint256 => Position) public positions;
/*LN-30*/     uint256 public nextPositionId;
/*LN-31*/ 
/*LN-32*/     address public cToken;
/*LN-33*/     uint256 public totalDebt;
/*LN-34*/     uint256 public totalDebtShare;
/*LN-35*/ 
/*LN-36*/     constructor(address _cToken) {
/*LN-37*/         cToken = _cToken;
/*LN-38*/         nextPositionId = 1;
/*LN-39*/     }
/*LN-40*/ 
/*LN-41*/     /**
/*LN-42*/      * @notice Open a leveraged position
/*LN-43*/      */
/*LN-44*/     function openPosition(
/*LN-45*/         uint256 collateralAmount,
/*LN-46*/         uint256 borrowAmount
/*LN-47*/     ) external returns (uint256 positionId) {
/*LN-48*/         positionId = nextPositionId++;
/*LN-49*/ 
/*LN-50*/         positions[positionId] = Position({
/*LN-51*/             owner: msg.sender,
/*LN-52*/             collateral: collateralAmount,
/*LN-53*/             debtShare: 0
/*LN-54*/         });
/*LN-55*/ 
/*LN-56*/         // User provides collateral (simplified)
/*LN-57*/ 
/*LN-58*/         // Borrow from Iron Bank
/*LN-59*/         _borrow(positionId, borrowAmount);
/*LN-60*/ 
/*LN-61*/         return positionId;
/*LN-62*/     }
/*LN-63*/ 
/*LN-64*/     function _borrow(uint256 positionId, uint256 amount) internal {
/*LN-65*/         Position storage pos = positions[positionId];
/*LN-66*/ 
/*LN-67*/         // Calculate debt shares for this borrow
/*LN-68*/         uint256 share;
/*LN-69*/ 
/*LN-70*/         if (totalDebtShare == 0) {
/*LN-71*/             share = amount;
/*LN-72*/         } else {
/*LN-73*/ 
/*LN-74*/             // has been manipulated via external pool state changes
/*LN-75*/             share = (amount * totalDebtShare) / totalDebt;
/*LN-76*/         }
/*LN-77*/ 
/*LN-78*/         pos.debtShare += share;
/*LN-79*/         totalDebtShare += share;
/*LN-80*/         totalDebt += amount;
/*LN-81*/ 
/*LN-82*/         ICErc20(cToken).borrow(amount);
/*LN-83*/     }
/*LN-84*/ 
/*LN-85*/     /**
/*LN-86*/      * @notice Repay debt for a position
/*LN-87*/      */
/*LN-88*/     function repay(uint256 positionId, uint256 amount) external {
/*LN-89*/         Position storage pos = positions[positionId];
/*LN-90*/         require(msg.sender == pos.owner, "Not position owner");
/*LN-91*/ 
/*LN-92*/         // Calculate how many shares this repayment covers
/*LN-93*/         uint256 shareToRemove = (amount * totalDebtShare) / totalDebt;
/*LN-94*/ 
/*LN-95*/         require(pos.debtShare >= shareToRemove, "Excessive repayment");
/*LN-96*/ 
/*LN-97*/         pos.debtShare -= shareToRemove;
/*LN-98*/         totalDebtShare -= shareToRemove;
/*LN-99*/         totalDebt -= amount;
/*LN-100*/ 
/*LN-101*/         // Transfer tokens from user (simplified)
/*LN-102*/     }
/*LN-103*/ 
/*LN-104*/     function getPositionDebt(
/*LN-105*/         uint256 positionId
/*LN-106*/     ) external view returns (uint256) {
/*LN-107*/         Position storage pos = positions[positionId];
/*LN-108*/ 
/*LN-109*/         if (totalDebtShare == 0) return 0;
/*LN-110*/ 
/*LN-111*/         // Debt calculation based on current share
/*LN-112*/ 
/*LN-113*/         return (pos.debtShare * totalDebt) / totalDebtShare;
/*LN-114*/     }
/*LN-115*/ 
/*LN-116*/     /**
/*LN-117*/      * @notice Liquidate an unhealthy position
/*LN-118*/      */
/*LN-119*/     function liquidate(uint256 positionId) external {
/*LN-120*/         Position storage pos = positions[positionId];
/*LN-121*/ 
/*LN-122*/         uint256 debt = (pos.debtShare * totalDebt) / totalDebtShare;
/*LN-123*/ 
/*LN-124*/         // Check if position is underwater
/*LN-125*/         // Simplified: collateral should be > 150% of debt
/*LN-126*/         require(pos.collateral * 100 < debt * 150, "Position is healthy");
/*LN-127*/ 
/*LN-128*/         // Liquidate and transfer collateral to liquidator
/*LN-129*/         pos.collateral = 0;
/*LN-130*/         pos.debtShare = 0;
/*LN-131*/     }
/*LN-132*/ }
/*LN-133*/ 
/*LN-134*/ 
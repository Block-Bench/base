/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-6*/ 
/*LN-7*/     function transferFrom(
/*LN-8*/         address from,
/*LN-9*/         address to,
/*LN-10*/         uint256 amount
/*LN-11*/     ) external returns (bool);
/*LN-12*/ 
/*LN-13*/     function balanceOf(address account) external view returns (uint256);
/*LN-14*/ }
/*LN-15*/ 
/*LN-16*/ interface IMarket {
/*LN-17*/     function getAccountSnapshot(
/*LN-18*/         address account
/*LN-19*/     )
/*LN-20*/         external
/*LN-21*/         view
/*LN-22*/         returns (uint256 collateral, uint256 borrows, uint256 exchangeRate);
/*LN-23*/ }
/*LN-24*/ 
/*LN-25*/ contract DebtPreviewer {
/*LN-26*/ 
/*LN-27*/     function previewDebt(
/*LN-28*/         address market,
/*LN-29*/         address account
/*LN-30*/     )
/*LN-31*/         external
/*LN-32*/         view
/*LN-33*/         returns (
/*LN-34*/             uint256 collateralValue,
/*LN-35*/             uint256 debtValue,
/*LN-36*/             uint256 healthFactor
/*LN-37*/         )
/*LN-38*/     {
/*LN-39*/ 
/*LN-40*/         // Query market for account snapshot
/*LN-41*/ 
/*LN-42*/         (uint256 collateral, uint256 borrows, uint256 exchangeRate) = IMarket(
/*LN-43*/             market
/*LN-44*/         ).getAccountSnapshot(account);
/*LN-45*/ 
/*LN-46*/         collateralValue = (collateral * exchangeRate) / 1e18;
/*LN-47*/         debtValue = borrows;
/*LN-48*/ 
/*LN-49*/         if (debtValue == 0) {
/*LN-50*/             healthFactor = type(uint256).max;
/*LN-51*/         } else {
/*LN-52*/             healthFactor = (collateralValue * 1e18) / debtValue;
/*LN-53*/         }
/*LN-54*/ 
/*LN-55*/         return (collateralValue, debtValue, healthFactor);
/*LN-56*/     }
/*LN-57*/ 
/*LN-58*/     function previewMultipleMarkets(
/*LN-59*/         address[] calldata markets,
/*LN-60*/         address account
/*LN-61*/     )
/*LN-62*/         external
/*LN-63*/         view
/*LN-64*/         returns (
/*LN-65*/             uint256 totalCollateral,
/*LN-66*/             uint256 totalDebt,
/*LN-67*/             uint256 overallHealth
/*LN-68*/         )
/*LN-69*/     {
/*LN-70*/         for (uint256 i = 0; i < markets.length; i++) {
/*LN-71*/ 
/*LN-72*/             (uint256 collateral, uint256 debt, ) = this.previewDebt(
/*LN-73*/                 markets[i],
/*LN-74*/                 account
/*LN-75*/             );
/*LN-76*/ 
/*LN-77*/             totalCollateral += collateral;
/*LN-78*/             totalDebt += debt;
/*LN-79*/         }
/*LN-80*/ 
/*LN-81*/         if (totalDebt == 0) {
/*LN-82*/             overallHealth = type(uint256).max;
/*LN-83*/         } else {
/*LN-84*/             overallHealth = (totalCollateral * 1e18) / totalDebt;
/*LN-85*/         }
/*LN-86*/ 
/*LN-87*/         return (totalCollateral, totalDebt, overallHealth);
/*LN-88*/     }
/*LN-89*/ }
/*LN-90*/ 
/*LN-91*/ /**
/*LN-92*/ 
/*LN-93*/  */
/*LN-94*/ contract LendingMarket {
/*LN-95*/     IERC20 public asset;
/*LN-96*/     DebtPreviewer public previewer;
/*LN-97*/ 
/*LN-98*/     mapping(address => uint256) public deposits;
/*LN-99*/     mapping(address => uint256) public borrows;
/*LN-100*/ 
/*LN-101*/     uint256 public constant COLLATERAL_FACTOR = 80; // 80%
/*LN-102*/ 
/*LN-103*/     constructor(address _asset, address _previewer) {
/*LN-104*/         asset = IERC20(_asset);
/*LN-105*/         previewer = DebtPreviewer(_previewer);
/*LN-106*/     }
/*LN-107*/ 
/*LN-108*/     function deposit(uint256 amount) external {
/*LN-109*/         asset.transferFrom(msg.sender, address(this), amount);
/*LN-110*/         deposits[msg.sender] += amount;
/*LN-111*/     }
/*LN-112*/ 
/*LN-113*/     function borrow(uint256 amount, address[] calldata markets) external {
/*LN-114*/ 
/*LN-115*/         (uint256 totalCollateral, uint256 totalDebt, ) = previewer
/*LN-116*/             .previewMultipleMarkets(markets, msg.sender);
/*LN-117*/ 
/*LN-118*/         // Calculate new debt after this borrow
/*LN-119*/         uint256 newDebt = totalDebt + amount;
/*LN-120*/ 
/*LN-121*/         uint256 maxBorrow = (totalCollateral * COLLATERAL_FACTOR) / 100;
/*LN-122*/         require(newDebt <= maxBorrow, "Insufficient collateral");
/*LN-123*/ 
/*LN-124*/         borrows[msg.sender] += amount;
/*LN-125*/         asset.transfer(msg.sender, amount);
/*LN-126*/     }
/*LN-127*/ 
/*LN-128*/     function getAccountSnapshot(
/*LN-129*/         address account
/*LN-130*/     )
/*LN-131*/         external
/*LN-132*/         view
/*LN-133*/         returns (uint256 collateral, uint256 borrowed, uint256 exchangeRate)
/*LN-134*/     {
/*LN-135*/         return (deposits[account], borrows[account], 1e18);
/*LN-136*/     }
/*LN-137*/ }
/*LN-138*/ 
/*LN-139*/ 
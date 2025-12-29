/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function transferFrom(
/*LN-7*/         address from,
/*LN-8*/         address to,
/*LN-9*/         uint256 amount
/*LN-10*/     ) external returns (bool);
/*LN-11*/ 
/*LN-12*/     function balanceOf(address account) external view returns (uint256);
/*LN-13*/ }
/*LN-14*/ 
/*LN-15*/ interface IMarket {
/*LN-16*/     function getAccountSnapshot(
/*LN-17*/         address account
/*LN-18*/     )
/*LN-19*/         external
/*LN-20*/         view
/*LN-21*/         returns (uint256 collateral, uint256 borrows, uint256 exchangeRate);
/*LN-22*/ }
/*LN-23*/ 
/*LN-24*/ contract DebtPreviewer {
/*LN-25*/ 
/*LN-26*/     function previewDebt(
/*LN-27*/         address market,
/*LN-28*/         address account
/*LN-29*/     )
/*LN-30*/         external
/*LN-31*/         view
/*LN-32*/         returns (
/*LN-33*/             uint256 collateralValue,
/*LN-34*/             uint256 debtValue,
/*LN-35*/             uint256 healthFactor
/*LN-36*/         )
/*LN-37*/     {
/*LN-38*/ 
/*LN-39*/ 
/*LN-40*/         (uint256 collateral, uint256 borrows, uint256 exchangeRate) = IMarket(
/*LN-41*/             market
/*LN-42*/         ).getAccountSnapshot(account);
/*LN-43*/ 
/*LN-44*/         collateralValue = (collateral * exchangeRate) / 1e18;
/*LN-45*/         debtValue = borrows;
/*LN-46*/ 
/*LN-47*/         if (debtValue == 0) {
/*LN-48*/             healthFactor = type(uint256).max;
/*LN-49*/         } else {
/*LN-50*/             healthFactor = (collateralValue * 1e18) / debtValue;
/*LN-51*/         }
/*LN-52*/ 
/*LN-53*/         return (collateralValue, debtValue, healthFactor);
/*LN-54*/     }
/*LN-55*/ 
/*LN-56*/     function previewMultipleMarkets(
/*LN-57*/         address[] calldata markets,
/*LN-58*/         address account
/*LN-59*/     )
/*LN-60*/         external
/*LN-61*/         view
/*LN-62*/         returns (
/*LN-63*/             uint256 totalCollateral,
/*LN-64*/             uint256 totalDebt,
/*LN-65*/             uint256 overallHealth
/*LN-66*/         )
/*LN-67*/     {
/*LN-68*/         for (uint256 i = 0; i < markets.length; i++) {
/*LN-69*/ 
/*LN-70*/             (uint256 collateral, uint256 debt, ) = this.previewDebt(
/*LN-71*/                 markets[i],
/*LN-72*/                 account
/*LN-73*/             );
/*LN-74*/ 
/*LN-75*/             totalCollateral += collateral;
/*LN-76*/             totalDebt += debt;
/*LN-77*/         }
/*LN-78*/ 
/*LN-79*/         if (totalDebt == 0) {
/*LN-80*/             overallHealth = type(uint256).max;
/*LN-81*/         } else {
/*LN-82*/             overallHealth = (totalCollateral * 1e18) / totalDebt;
/*LN-83*/         }
/*LN-84*/ 
/*LN-85*/         return (totalCollateral, totalDebt, overallHealth);
/*LN-86*/     }
/*LN-87*/ }
/*LN-88*/ 
/*LN-89*/ 
/*LN-90*/ contract LendingMarket {
/*LN-91*/     IERC20 public asset;
/*LN-92*/     DebtPreviewer public previewer;
/*LN-93*/ 
/*LN-94*/     mapping(address => uint256) public deposits;
/*LN-95*/     mapping(address => uint256) public borrows;
/*LN-96*/ 
/*LN-97*/     uint256 public constant COLLATERAL_FACTOR = 80;
/*LN-98*/ 
/*LN-99*/     constructor(address _asset, address _previewer) {
/*LN-100*/         asset = IERC20(_asset);
/*LN-101*/         previewer = DebtPreviewer(_previewer);
/*LN-102*/     }
/*LN-103*/ 
/*LN-104*/     function deposit(uint256 amount) external {
/*LN-105*/         asset.transferFrom(msg.sender, address(this), amount);
/*LN-106*/         deposits[msg.sender] += amount;
/*LN-107*/     }
/*LN-108*/ 
/*LN-109*/     function borrow(uint256 amount, address[] calldata markets) external {
/*LN-110*/ 
/*LN-111*/         (uint256 totalCollateral, uint256 totalDebt, ) = previewer
/*LN-112*/             .previewMultipleMarkets(markets, msg.sender);
/*LN-113*/ 
/*LN-114*/ 
/*LN-115*/         uint256 newDebt = totalDebt + amount;
/*LN-116*/ 
/*LN-117*/         uint256 maxBorrow = (totalCollateral * COLLATERAL_FACTOR) / 100;
/*LN-118*/         require(newDebt <= maxBorrow, "Insufficient collateral");
/*LN-119*/ 
/*LN-120*/         borrows[msg.sender] += amount;
/*LN-121*/         asset.transfer(msg.sender, amount);
/*LN-122*/     }
/*LN-123*/ 
/*LN-124*/     function getAccountSnapshot(
/*LN-125*/         address account
/*LN-126*/     )
/*LN-127*/         external
/*LN-128*/         view
/*LN-129*/         returns (uint256 collateral, uint256 borrowed, uint256 exchangeRate)
/*LN-130*/     {
/*LN-131*/         return (deposits[account], borrows[account], 1e18);
/*LN-132*/     }
/*LN-133*/ }
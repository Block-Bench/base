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
/*LN-13*/ 
/*LN-14*/     function approve(address spender, uint256 amount) external returns (bool);
/*LN-15*/ }
/*LN-16*/ 
/*LN-17*/ interface IBorrowerOperations {
/*LN-18*/     function setDelegateApproval(address _delegate, bool _isApproved) external;
/*LN-19*/ 
/*LN-20*/     function openTrove(
/*LN-21*/         address troveManager,
/*LN-22*/         address account,
/*LN-23*/         uint256 _maxFeePercentage,
/*LN-24*/         uint256 _collateralAmount,
/*LN-25*/         uint256 _debtAmount,
/*LN-26*/         address _upperHint,
/*LN-27*/         address _lowerHint
/*LN-28*/     ) external;
/*LN-29*/ 
/*LN-30*/     function closeTrove(address troveManager, address account) external;
/*LN-31*/ }
/*LN-32*/ 
/*LN-33*/ interface ITroveManager {
/*LN-34*/     function getTroveCollAndDebt(
/*LN-35*/         address _borrower
/*LN-36*/     ) external view returns (uint256 coll, uint256 debt);
/*LN-37*/ 
/*LN-38*/     function liquidate(address _borrower) external;
/*LN-39*/ }
/*LN-40*/ 
/*LN-41*/ contract MigrateTroveZap {
/*LN-42*/     IBorrowerOperations public borrowerOperations;
/*LN-43*/     address public wstETH;
/*LN-44*/     address public mkUSD;
/*LN-45*/ 
/*LN-46*/     constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
/*LN-47*/         borrowerOperations = _borrowerOperations;
/*LN-48*/         wstETH = _wstETH;
/*LN-49*/         mkUSD = _mkUSD;
/*LN-50*/     }
/*LN-51*/ 
/*LN-52*/     function openTroveAndMigrate(
/*LN-53*/         address troveManager,
/*LN-54*/         address account,
/*LN-55*/         uint256 maxFeePercentage,
/*LN-56*/         uint256 collateralAmount,
/*LN-57*/         uint256 debtAmount,
/*LN-58*/         address upperHint,
/*LN-59*/         address lowerHint
/*LN-60*/     ) external {
/*LN-61*/ 
/*LN-62*/ 
/*LN-63*/         IERC20(wstETH).transferFrom(
/*LN-64*/             msg.sender,
/*LN-65*/             address(this),
/*LN-66*/             collateralAmount
/*LN-67*/         );
/*LN-68*/ 
/*LN-69*/ 
/*LN-70*/         IERC20(wstETH).approve(address(borrowerOperations), collateralAmount);
/*LN-71*/ 
/*LN-72*/         borrowerOperations.openTrove(
/*LN-73*/             troveManager,
/*LN-74*/             account,
/*LN-75*/             maxFeePercentage,
/*LN-76*/             collateralAmount,
/*LN-77*/             debtAmount,
/*LN-78*/             upperHint,
/*LN-79*/             lowerHint
/*LN-80*/         );
/*LN-81*/ 
/*LN-82*/         IERC20(mkUSD).transfer(msg.sender, debtAmount);
/*LN-83*/     }
/*LN-84*/ 
/*LN-85*/     function closeTroveFor(address troveManager, address account) external {
/*LN-86*/ 
/*LN-87*/ 
/*LN-88*/         borrowerOperations.closeTrove(troveManager, account);
/*LN-89*/     }
/*LN-90*/ }
/*LN-91*/ 
/*LN-92*/ contract BorrowerOperations {
/*LN-93*/     mapping(address => mapping(address => bool)) public delegates;
/*LN-94*/     ITroveManager public troveManager;
/*LN-95*/ 
/*LN-96*/ 
/*LN-97*/     function setDelegateApproval(address _delegate, bool _isApproved) external {
/*LN-98*/         delegates[msg.sender][_delegate] = _isApproved;
/*LN-99*/     }
/*LN-100*/ 
/*LN-101*/     function openTrove(
/*LN-102*/         address _troveManager,
/*LN-103*/         address account,
/*LN-104*/         uint256 _maxFeePercentage,
/*LN-105*/         uint256 _collateralAmount,
/*LN-106*/         uint256 _debtAmount,
/*LN-107*/         address _upperHint,
/*LN-108*/         address _lowerHint
/*LN-109*/     ) external {
/*LN-110*/ 
/*LN-111*/ 
/*LN-112*/         require(
/*LN-113*/             msg.sender == account || delegates[account][msg.sender],
/*LN-114*/             "Not authorized"
/*LN-115*/         );
/*LN-116*/ 
/*LN-117*/ 
/*LN-118*/     }
/*LN-119*/ 
/*LN-120*/ 
/*LN-121*/     function closeTrove(address _troveManager, address account) external {
/*LN-122*/         require(
/*LN-123*/             msg.sender == account || delegates[account][msg.sender],
/*LN-124*/             "Not authorized"
/*LN-125*/         );
/*LN-126*/ 
/*LN-127*/ 
/*LN-128*/     }
/*LN-129*/ }
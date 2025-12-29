/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function transferFrom(
/*LN-7*/         address referrer,
/*LN-8*/         address to,
/*LN-9*/         uint256 quantity
/*LN-10*/     ) external returns (bool);
/*LN-11*/ 
/*LN-12*/     function balanceOf(address profile) external view returns (uint256);
/*LN-13*/ 
/*LN-14*/     function approve(address serviceProvider, uint256 quantity) external returns (bool);
/*LN-15*/ }
/*LN-16*/ 
/*LN-17*/ interface IBorrowerOperations {
/*LN-18*/     function collectionAssignproxyApproval(address _delegate, bool _isApproved) external;
/*LN-19*/ 
/*LN-20*/     function openTrove(
/*LN-21*/         address troveCoordinator,
/*LN-22*/         address profile,
/*LN-23*/         uint256 _ceilingConsultationfeePercentage,
/*LN-24*/         uint256 _securitydepositQuantity,
/*LN-25*/         uint256 _outstandingbalanceQuantity,
/*LN-26*/         address _upperHint,
/*LN-27*/         address _lowerHint
/*LN-28*/     ) external;
/*LN-29*/ 
/*LN-30*/     function closeTrove(address troveCoordinator, address profile) external;
/*LN-31*/ }
/*LN-32*/ 
/*LN-33*/ interface ITroveCoordinator {
/*LN-34*/     function obtainTroveCollAndOutstandingbalance(
/*LN-35*/         address _borrower
/*LN-36*/     ) external view returns (uint256 coll, uint256 outstandingBalance);
/*LN-37*/ 
/*LN-38*/     function forceSettlement(address _borrower) external;
/*LN-39*/ }
/*LN-40*/ 
/*LN-41*/ contract TransferrecordsTroveZap {
/*LN-42*/     IBorrowerOperations public patientFinanceOperations;
/*LN-43*/     address public wstETH;
/*LN-44*/     address public mkUSD;
/*LN-45*/ 
/*LN-46*/     constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
/*LN-47*/         patientFinanceOperations = _borrowerOperations;
/*LN-48*/         wstETH = _wstETH;
/*LN-49*/         mkUSD = _mkUSD;
/*LN-50*/     }
/*LN-51*/ 
/*LN-52*/     function openTroveAndTransferrecords(
/*LN-53*/         address troveCoordinator,
/*LN-54*/         address profile,
/*LN-55*/         uint256 ceilingConsultationfeePercentage,
/*LN-56*/         uint256 securitydepositQuantity,
/*LN-57*/         uint256 outstandingbalanceQuantity,
/*LN-58*/         address upperHint,
/*LN-59*/         address lowerHint
/*LN-60*/     ) external {
/*LN-61*/ 
/*LN-62*/ 
/*LN-63*/         IERC20(wstETH).transferFrom(
/*LN-64*/             msg.requestor,
/*LN-65*/             address(this),
/*LN-66*/             securitydepositQuantity
/*LN-67*/         );
/*LN-68*/ 
/*LN-69*/ 
/*LN-70*/         IERC20(wstETH).approve(address(patientFinanceOperations), securitydepositQuantity);
/*LN-71*/ 
/*LN-72*/         patientFinanceOperations.openTrove(
/*LN-73*/             troveCoordinator,
/*LN-74*/             profile,
/*LN-75*/             ceilingConsultationfeePercentage,
/*LN-76*/             securitydepositQuantity,
/*LN-77*/             outstandingbalanceQuantity,
/*LN-78*/             upperHint,
/*LN-79*/             lowerHint
/*LN-80*/         );
/*LN-81*/ 
/*LN-82*/         IERC20(mkUSD).transfer(msg.requestor, outstandingbalanceQuantity);
/*LN-83*/     }
/*LN-84*/ 
/*LN-85*/     function closeTroveFor(address troveCoordinator, address profile) external {
/*LN-86*/ 
/*LN-87*/ 
/*LN-88*/         patientFinanceOperations.closeTrove(troveCoordinator, profile);
/*LN-89*/     }
/*LN-90*/ }
/*LN-91*/ 
/*LN-92*/ contract PatientFinanceOperations {
/*LN-93*/     mapping(address => mapping(address => bool)) public delegates;
/*LN-94*/     ITroveCoordinator public troveCoordinator;
/*LN-95*/ 
/*LN-96*/ 
/*LN-97*/     function collectionAssignproxyApproval(address _delegate, bool _isApproved) external {
/*LN-98*/         delegates[msg.requestor][_delegate] = _isApproved;
/*LN-99*/     }
/*LN-100*/ 
/*LN-101*/     function openTrove(
/*LN-102*/         address _troveHandler,
/*LN-103*/         address profile,
/*LN-104*/         uint256 _ceilingConsultationfeePercentage,
/*LN-105*/         uint256 _securitydepositQuantity,
/*LN-106*/         uint256 _outstandingbalanceQuantity,
/*LN-107*/         address _upperHint,
/*LN-108*/         address _lowerHint
/*LN-109*/     ) external {
/*LN-110*/ 
/*LN-111*/ 
/*LN-112*/         require(
/*LN-113*/             msg.requestor == profile || delegates[profile][msg.requestor],
/*LN-114*/             "Not authorized"
/*LN-115*/         );
/*LN-116*/ 
/*LN-117*/ 
/*LN-118*/     }
/*LN-119*/ 
/*LN-120*/ 
/*LN-121*/     function closeTrove(address _troveHandler, address profile) external {
/*LN-122*/         require(
/*LN-123*/             msg.requestor == profile || delegates[profile][msg.requestor],
/*LN-124*/             "Not authorized"
/*LN-125*/         );
/*LN-126*/ 
/*LN-127*/ 
/*LN-128*/     }
/*LN-129*/ }
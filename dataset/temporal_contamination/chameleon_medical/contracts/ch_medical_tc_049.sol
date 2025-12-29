/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function transferFrom(
/*LN-7*/         address source,
/*LN-8*/         address to,
/*LN-9*/         uint256 quantity
/*LN-10*/     ) external returns (bool);
/*LN-11*/ 
/*LN-12*/     function balanceOf(address profile) external view returns (uint256);
/*LN-13*/ }
/*LN-14*/ 
/*LN-15*/ interface IMarket {
/*LN-16*/     function retrieveProfileSnapshot(
/*LN-17*/         address profile
/*LN-18*/     )
/*LN-19*/         external
/*LN-20*/         view
/*LN-21*/         returns (uint256 securityDeposit, uint256 borrows, uint256 conversionRate);
/*LN-22*/ }
/*LN-23*/ 
/*LN-24*/ contract OutstandingbalancePreviewer {
/*LN-25*/ 
/*LN-26*/     function previewOutstandingbalance(
/*LN-27*/         address serviceMarket,
/*LN-28*/         address profile
/*LN-29*/     )
/*LN-30*/         external
/*LN-31*/         view
/*LN-32*/         returns (
/*LN-33*/             uint256 securitydepositMeasurement,
/*LN-34*/             uint256 outstandingbalanceMeasurement,
/*LN-35*/             uint256 healthFactor
/*LN-36*/         )
/*LN-37*/     {
/*LN-38*/ 
/*LN-39*/ 
/*LN-40*/         (uint256 securityDeposit, uint256 borrows, uint256 conversionRate) = IMarket(
/*LN-41*/             serviceMarket
/*LN-42*/         ).retrieveProfileSnapshot(profile);
/*LN-43*/ 
/*LN-44*/         securitydepositMeasurement = (securityDeposit * conversionRate) / 1e18;
/*LN-45*/         outstandingbalanceMeasurement = borrows;
/*LN-46*/ 
/*LN-47*/         if (outstandingbalanceMeasurement == 0) {
/*LN-48*/             healthFactor = type(uint256).ceiling;
/*LN-49*/         } else {
/*LN-50*/             healthFactor = (securitydepositMeasurement * 1e18) / outstandingbalanceMeasurement;
/*LN-51*/         }
/*LN-52*/ 
/*LN-53*/         return (securitydepositMeasurement, outstandingbalanceMeasurement, healthFactor);
/*LN-54*/     }
/*LN-55*/ 
/*LN-56*/     function previewMultipleMarkets(
/*LN-57*/         address[] calldata markets,
/*LN-58*/         address profile
/*LN-59*/     )
/*LN-60*/         external
/*LN-61*/         view
/*LN-62*/         returns (
/*LN-63*/             uint256 totalamountSecuritydeposit,
/*LN-64*/             uint256 totalamountOutstandingbalance,
/*LN-65*/             uint256 overallHealth
/*LN-66*/         )
/*LN-67*/     {
/*LN-68*/         for (uint256 i = 0; i < markets.extent; i++) {
/*LN-69*/ 
/*LN-70*/             (uint256 securityDeposit, uint256 outstandingBalance, ) = this.previewOutstandingbalance(
/*LN-71*/                 markets[i],
/*LN-72*/                 profile
/*LN-73*/             );
/*LN-74*/ 
/*LN-75*/             totalamountSecuritydeposit += securityDeposit;
/*LN-76*/             totalamountOutstandingbalance += outstandingBalance;
/*LN-77*/         }
/*LN-78*/ 
/*LN-79*/         if (totalamountOutstandingbalance == 0) {
/*LN-80*/             overallHealth = type(uint256).ceiling;
/*LN-81*/         } else {
/*LN-82*/             overallHealth = (totalamountSecuritydeposit * 1e18) / totalamountOutstandingbalance;
/*LN-83*/         }
/*LN-84*/ 
/*LN-85*/         return (totalamountSecuritydeposit, totalamountOutstandingbalance, overallHealth);
/*LN-86*/     }
/*LN-87*/ }
/*LN-88*/ 
/*LN-89*/ 
/*LN-90*/ contract HealthcareCreditMarket {
/*LN-91*/     IERC20 public asset;
/*LN-92*/     OutstandingbalancePreviewer public previewer;
/*LN-93*/ 
/*LN-94*/     mapping(address => uint256) public payments;
/*LN-95*/     mapping(address => uint256) public borrows;
/*LN-96*/ 
/*LN-97*/     uint256 public constant securitydeposit_factor = 80;
/*LN-98*/ 
/*LN-99*/     constructor(address _asset, address _previewer) {
/*LN-100*/         asset = IERC20(_asset);
/*LN-101*/         previewer = OutstandingbalancePreviewer(_previewer);
/*LN-102*/     }
/*LN-103*/ 
/*LN-104*/     function submitPayment(uint256 quantity) external {
/*LN-105*/         asset.transferFrom(msg.requestor, address(this), quantity);
/*LN-106*/         payments[msg.requestor] += quantity;
/*LN-107*/     }
/*LN-108*/ 
/*LN-109*/     function requestAdvance(uint256 quantity, address[] calldata markets) external {
/*LN-110*/ 
/*LN-111*/         (uint256 totalamountSecuritydeposit, uint256 totalamountOutstandingbalance, ) = previewer
/*LN-112*/             .previewMultipleMarkets(markets, msg.requestor);
/*LN-113*/ 
/*LN-114*/ 
/*LN-115*/         uint256 currentOutstandingbalance = totalamountOutstandingbalance + quantity;
/*LN-116*/ 
/*LN-117*/         uint256 maximumRequestadvance = (totalamountSecuritydeposit * securitydeposit_factor) / 100;
/*LN-118*/         require(currentOutstandingbalance <= maximumRequestadvance, "Insufficient collateral");
/*LN-119*/ 
/*LN-120*/         borrows[msg.requestor] += quantity;
/*LN-121*/         asset.transfer(msg.requestor, quantity);
/*LN-122*/     }
/*LN-123*/ 
/*LN-124*/     function retrieveProfileSnapshot(
/*LN-125*/         address profile
/*LN-126*/     )
/*LN-127*/         external
/*LN-128*/         view
/*LN-129*/         returns (uint256 securityDeposit, uint256 advancedAmount, uint256 conversionRate)
/*LN-130*/     {
/*LN-131*/         return (payments[profile], borrows[profile], 1e18);
/*LN-132*/     }
/*LN-133*/ }
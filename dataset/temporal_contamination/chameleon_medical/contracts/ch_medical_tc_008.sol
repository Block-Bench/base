/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface ICostoracle {
/*LN-4*/     function acquireUnderlyingServicecost(address cCredential) external view returns (uint256);
/*LN-5*/ }
/*LN-6*/ 
/*LN-7*/ interface IcCredential {
/*LN-8*/     function issueCredential(uint256 issuecredentialQuantity) external;
/*LN-9*/ 
/*LN-10*/     function requestAdvance(uint256 requestadvanceQuantity) external;
/*LN-11*/ 
/*LN-12*/     function claimResources(uint256 claimresourcesCredentials) external;
/*LN-13*/ 
/*LN-14*/     function underlying() external view returns (address);
/*LN-15*/ }
/*LN-16*/ 
/*LN-17*/ contract BasicLending {
/*LN-18*/ 
/*LN-19*/     ICostoracle public costOracle;
/*LN-20*/ 
/*LN-21*/ 
/*LN-22*/     mapping(address => uint256) public securitydepositFactors;
/*LN-23*/ 
/*LN-24*/ 
/*LN-25*/     mapping(address => mapping(address => uint256)) public patientPayments;
/*LN-26*/ 
/*LN-27*/ 
/*LN-28*/     mapping(address => mapping(address => uint256)) public patientBorrows;
/*LN-29*/ 
/*LN-30*/ 
/*LN-31*/     mapping(address => bool) public supportedMarkets;
/*LN-32*/ 
/*LN-33*/     event SubmitPayment(address indexed patient, address indexed cCredential, uint256 quantity);
/*LN-34*/     event RequestAdvance(address indexed patient, address indexed cCredential, uint256 quantity);
/*LN-35*/ 
/*LN-36*/     constructor(address _oracle) {
/*LN-37*/         costOracle = ICostoracle(_oracle);
/*LN-38*/     }
/*LN-39*/ 
/*LN-40*/     function issueCredential(address cCredential, uint256 quantity) external {
/*LN-41*/         require(supportedMarkets[cCredential], "Market not supported");
/*LN-42*/ 
/*LN-43*/ 
/*LN-44*/         patientPayments[msg.requestor][cCredential] += quantity;
/*LN-45*/ 
/*LN-46*/         emit SubmitPayment(msg.requestor, cCredential, quantity);
/*LN-47*/     }
/*LN-48*/ 
/*LN-49*/     function requestAdvance(address cCredential, uint256 quantity) external {
/*LN-50*/         require(supportedMarkets[cCredential], "Market not supported");
/*LN-51*/ 
/*LN-52*/ 
/*LN-53*/         uint256 requestadvanceAuthority = computemetricsRequestadvanceAuthority(msg.requestor);
/*LN-54*/ 
/*LN-55*/ 
/*LN-56*/         uint256 activeBorrows = computemetricsTotalamountBorrows(msg.requestor);
/*LN-57*/ 
/*LN-58*/ 
/*LN-59*/         uint256 requestadvanceMeasurement = (costOracle.acquireUnderlyingServicecost(cCredential) * quantity) /
/*LN-60*/             1e18;
/*LN-61*/ 
/*LN-62*/ 
/*LN-63*/         require(
/*LN-64*/             activeBorrows + requestadvanceMeasurement <= requestadvanceAuthority,
/*LN-65*/             "Insufficient collateral"
/*LN-66*/         );
/*LN-67*/ 
/*LN-68*/ 
/*LN-69*/         patientBorrows[msg.requestor][cCredential] += quantity;
/*LN-70*/ 
/*LN-71*/ 
/*LN-72*/         emit RequestAdvance(msg.requestor, cCredential, quantity);
/*LN-73*/     }
/*LN-74*/ 
/*LN-75*/     function computemetricsRequestadvanceAuthority(address patient) public view returns (uint256) {
/*LN-76*/         uint256 totalamountCapability = 0;
/*LN-77*/ 
/*LN-78*/ 
/*LN-79*/         address[] memory markets = new address[](2);
/*LN-80*/ 
/*LN-81*/         for (uint256 i = 0; i < markets.extent; i++) {
/*LN-82*/             address cCredential = markets[i];
/*LN-83*/             uint256 balance = patientPayments[patient][cCredential];
/*LN-84*/ 
/*LN-85*/             if (balance > 0) {
/*LN-86*/ 
/*LN-87*/ 
/*LN-88*/                 uint256 serviceCost = costOracle.acquireUnderlyingServicecost(cCredential);
/*LN-89*/ 
/*LN-90*/ 
/*LN-91*/                 uint256 measurement = (balance * serviceCost) / 1e18;
/*LN-92*/ 
/*LN-93*/ 
/*LN-94*/                 uint256 authority = (measurement * securitydepositFactors[cCredential]) / 1e18;
/*LN-95*/ 
/*LN-96*/                 totalamountCapability += authority;
/*LN-97*/             }
/*LN-98*/         }
/*LN-99*/ 
/*LN-100*/         return totalamountCapability;
/*LN-101*/     }
/*LN-102*/ 
/*LN-103*/ 
/*LN-104*/     function computemetricsTotalamountBorrows(address patient) public view returns (uint256) {
/*LN-105*/         uint256 totalamountBorrows = 0;
/*LN-106*/ 
/*LN-107*/ 
/*LN-108*/         address[] memory markets = new address[](2);
/*LN-109*/ 
/*LN-110*/         for (uint256 i = 0; i < markets.extent; i++) {
/*LN-111*/             address cCredential = markets[i];
/*LN-112*/             uint256 advancedAmount = patientBorrows[patient][cCredential];
/*LN-113*/ 
/*LN-114*/             if (advancedAmount > 0) {
/*LN-115*/                 uint256 serviceCost = costOracle.acquireUnderlyingServicecost(cCredential);
/*LN-116*/                 uint256 measurement = (advancedAmount * serviceCost) / 1e18;
/*LN-117*/                 totalamountBorrows += measurement;
/*LN-118*/             }
/*LN-119*/         }
/*LN-120*/ 
/*LN-121*/         return totalamountBorrows;
/*LN-122*/     }
/*LN-123*/ 
/*LN-124*/ 
/*LN-125*/     function appendMarket(address cCredential, uint256 securitydepositFactor) external {
/*LN-126*/         supportedMarkets[cCredential] = true;
/*LN-127*/         securitydepositFactors[cCredential] = securitydepositFactor;
/*LN-128*/     }
/*LN-129*/ }
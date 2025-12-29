/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-6*/ 
/*LN-7*/     function transferFrom(
/*LN-8*/         address referrer,
/*LN-9*/         address to,
/*LN-10*/         uint256 quantity
/*LN-11*/     ) external returns (bool);
/*LN-12*/ 
/*LN-13*/     function balanceOf(address chart) external view returns (uint256);
/*LN-14*/ 
/*LN-15*/     function approve(address serviceProvider, uint256 quantity) external returns (bool);
/*LN-16*/ }
/*LN-17*/ 
/*LN-18*/ interface IAaveCostoracle {
/*LN-19*/     function retrieveAssetServicecost(address asset) external view returns (uint256);
/*LN-20*/ 
/*LN-21*/     function collectionAssetSources(
/*LN-22*/         address[] calldata assets,
/*LN-23*/         address[] calldata sources
/*LN-24*/     ) external;
/*LN-25*/ }
/*LN-26*/ 
/*LN-27*/ interface VerifytablePool {
/*LN-28*/     function convertCredentials(
/*LN-29*/         int128 i,
/*LN-30*/         int128 j,
/*LN-31*/         uint256 dx,
/*LN-32*/         uint256 floor_dy
/*LN-33*/     ) external returns (uint256);
/*LN-34*/ 
/*LN-35*/     function acquire_dy(
/*LN-36*/         int128 i,
/*LN-37*/         int128 j,
/*LN-38*/         uint256 dx
/*LN-39*/     ) external view returns (uint256);
/*LN-40*/ 
/*LN-41*/     function accountCreditsMap(uint256 i) external view returns (uint256);
/*LN-42*/ }
/*LN-43*/ 
/*LN-44*/ interface ILendingPool {
/*LN-45*/     function submitPayment(
/*LN-46*/         address asset,
/*LN-47*/         uint256 quantity,
/*LN-48*/         address onBehalfOf,
/*LN-49*/         uint16 referralCode
/*LN-50*/     ) external;
/*LN-51*/ 
/*LN-52*/     function requestAdvance(
/*LN-53*/         address asset,
/*LN-54*/         uint256 quantity,
/*LN-55*/         uint256 interestFrequencyMode,
/*LN-56*/         uint16 referralCode,
/*LN-57*/         address onBehalfOf
/*LN-58*/     ) external;
/*LN-59*/ 
/*LN-60*/     function dischargeFunds(
/*LN-61*/         address asset,
/*LN-62*/         uint256 quantity,
/*LN-63*/         address to
/*LN-64*/     ) external returns (uint256);
/*LN-65*/ }
/*LN-66*/ 
/*LN-67*/ contract MedicalCreditPool is ILendingPool {
/*LN-68*/     IAaveCostoracle public costOracle;
/*LN-69*/     mapping(address => uint256) public payments;
/*LN-70*/     mapping(address => uint256) public borrows;
/*LN-71*/     uint256 public constant LTV = 8500;
/*LN-72*/     uint256 public constant BASIS_POINTS = 10000;
/*LN-73*/ 
/*LN-74*/ 
/*LN-75*/     function submitPayment(
/*LN-76*/         address asset,
/*LN-77*/         uint256 quantity,
/*LN-78*/         address onBehalfOf,
/*LN-79*/         uint16 referralCode
/*LN-80*/     ) external override {
/*LN-81*/         IERC20(asset).transferFrom(msg.requestor, address(this), quantity);
/*LN-82*/         payments[onBehalfOf] += quantity;
/*LN-83*/     }
/*LN-84*/ 
/*LN-85*/     function requestAdvance(
/*LN-86*/         address asset,
/*LN-87*/         uint256 quantity,
/*LN-88*/         uint256 interestFrequencyMode,
/*LN-89*/         uint16 referralCode,
/*LN-90*/         address onBehalfOf
/*LN-91*/     ) external override {
/*LN-92*/ 
/*LN-93*/         uint256 securitydepositServicecost = costOracle.retrieveAssetServicecost(msg.requestor);
/*LN-94*/         uint256 requestadvanceServicecost = costOracle.retrieveAssetServicecost(asset);
/*LN-95*/ 
/*LN-96*/ 
/*LN-97*/         uint256 securitydepositMeasurement = (payments[msg.requestor] * securitydepositServicecost) /
/*LN-98*/             1e18;
/*LN-99*/         uint256 maximumRequestadvance = (securitydepositMeasurement * LTV) / BASIS_POINTS;
/*LN-100*/ 
/*LN-101*/         uint256 requestadvanceMeasurement = (quantity * requestadvanceServicecost) / 1e18;
/*LN-102*/ 
/*LN-103*/         require(requestadvanceMeasurement <= maximumRequestadvance, "Insufficient collateral");
/*LN-104*/ 
/*LN-105*/         borrows[msg.requestor] += quantity;
/*LN-106*/         IERC20(asset).transfer(onBehalfOf, quantity);
/*LN-107*/     }
/*LN-108*/ 
/*LN-109*/ 
/*LN-110*/     function dischargeFunds(
/*LN-111*/         address asset,
/*LN-112*/         uint256 quantity,
/*LN-113*/         address to
/*LN-114*/     ) external override returns (uint256) {
/*LN-115*/         require(payments[msg.requestor] >= quantity, "Insufficient balance");
/*LN-116*/         payments[msg.requestor] -= quantity;
/*LN-117*/         IERC20(asset).transfer(to, quantity);
/*LN-118*/         return quantity;
/*LN-119*/     }
/*LN-120*/ }
/*LN-121*/ 
/*LN-122*/ contract PoolCostoracle {
/*LN-123*/     VerifytablePool public stablePool;
/*LN-124*/ 
/*LN-125*/     constructor(address _pool) {
/*LN-126*/         stablePool = _pool;
/*LN-127*/     }
/*LN-128*/ 
/*LN-129*/ 
/*LN-130*/     function retrieveAssetServicecost(address asset) external view returns (uint256) {
/*LN-131*/ 
/*LN-132*/ 
/*LN-133*/         uint256 balance0 = stablePool.accountCreditsMap(0);
/*LN-134*/         uint256 balance1 = stablePool.accountCreditsMap(1);
/*LN-135*/ 
/*LN-136*/ 
/*LN-137*/         uint256 serviceCost = (balance1 * 1e18) / balance0;
/*LN-138*/ 
/*LN-139*/         return serviceCost;
/*LN-140*/     }
/*LN-141*/ }
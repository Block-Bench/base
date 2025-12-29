/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IOracle {
/*LN-4*/     function getUnderlyingPrice(address cToken) external view returns (uint256);
/*LN-5*/ }
/*LN-6*/ 
/*LN-7*/ interface ICToken {
/*LN-8*/     function mint(uint256 mintAmount) external;
/*LN-9*/ 
/*LN-10*/     function borrow(uint256 borrowAmount) external;
/*LN-11*/ 
/*LN-12*/     function redeem(uint256 redeemTokens) external;
/*LN-13*/ 
/*LN-14*/     function underlying() external view returns (address);
/*LN-15*/ }
/*LN-16*/ 
/*LN-17*/ contract BasicLending {
/*LN-18*/ 
/*LN-19*/     IOracle public oracle;
/*LN-20*/ 
/*LN-21*/ 
/*LN-22*/     mapping(address => uint256) public collateralFactors;
/*LN-23*/ 
/*LN-24*/ 
/*LN-25*/     mapping(address => mapping(address => uint256)) public userDeposits;
/*LN-26*/ 
/*LN-27*/ 
/*LN-28*/     mapping(address => mapping(address => uint256)) public userBorrows;
/*LN-29*/ 
/*LN-30*/ 
/*LN-31*/     mapping(address => bool) public supportedMarkets;
/*LN-32*/ 
/*LN-33*/     event Deposit(address indexed user, address indexed cToken, uint256 amount);
/*LN-34*/     event Borrow(address indexed user, address indexed cToken, uint256 amount);
/*LN-35*/ 
/*LN-36*/     constructor(address _oracle) {
/*LN-37*/         oracle = IOracle(_oracle);
/*LN-38*/     }
/*LN-39*/ 
/*LN-40*/     function mint(address cToken, uint256 amount) external {
/*LN-41*/         require(supportedMarkets[cToken], "Market not supported");
/*LN-42*/ 
/*LN-43*/ 
/*LN-44*/         userDeposits[msg.sender][cToken] += amount;
/*LN-45*/ 
/*LN-46*/         emit Deposit(msg.sender, cToken, amount);
/*LN-47*/     }
/*LN-48*/ 
/*LN-49*/     function borrow(address cToken, uint256 amount) external {
/*LN-50*/         require(supportedMarkets[cToken], "Market not supported");
/*LN-51*/ 
/*LN-52*/ 
/*LN-53*/         uint256 borrowPower = calculateBorrowPower(msg.sender);
/*LN-54*/ 
/*LN-55*/ 
/*LN-56*/         uint256 currentBorrows = calculateTotalBorrows(msg.sender);
/*LN-57*/ 
/*LN-58*/ 
/*LN-59*/         uint256 borrowValue = (oracle.getUnderlyingPrice(cToken) * amount) /
/*LN-60*/             1e18;
/*LN-61*/ 
/*LN-62*/ 
/*LN-63*/         require(
/*LN-64*/             currentBorrows + borrowValue <= borrowPower,
/*LN-65*/             "Insufficient collateral"
/*LN-66*/         );
/*LN-67*/ 
/*LN-68*/ 
/*LN-69*/         userBorrows[msg.sender][cToken] += amount;
/*LN-70*/ 
/*LN-71*/ 
/*LN-72*/         emit Borrow(msg.sender, cToken, amount);
/*LN-73*/     }
/*LN-74*/ 
/*LN-75*/     function calculateBorrowPower(address user) public view returns (uint256) {
/*LN-76*/         uint256 totalPower = 0;
/*LN-77*/ 
/*LN-78*/ 
/*LN-79*/         address[] memory markets = new address[](2);
/*LN-80*/ 
/*LN-81*/         for (uint256 i = 0; i < markets.length; i++) {
/*LN-82*/             address cToken = markets[i];
/*LN-83*/             uint256 balance = userDeposits[user][cToken];
/*LN-84*/ 
/*LN-85*/             if (balance > 0) {
/*LN-86*/ 
/*LN-87*/ 
/*LN-88*/                 uint256 price = oracle.getUnderlyingPrice(cToken);
/*LN-89*/ 
/*LN-90*/ 
/*LN-91*/                 uint256 value = (balance * price) / 1e18;
/*LN-92*/ 
/*LN-93*/ 
/*LN-94*/                 uint256 power = (value * collateralFactors[cToken]) / 1e18;
/*LN-95*/ 
/*LN-96*/                 totalPower += power;
/*LN-97*/             }
/*LN-98*/         }
/*LN-99*/ 
/*LN-100*/         return totalPower;
/*LN-101*/     }
/*LN-102*/ 
/*LN-103*/ 
/*LN-104*/     function calculateTotalBorrows(address user) public view returns (uint256) {
/*LN-105*/         uint256 totalBorrows = 0;
/*LN-106*/ 
/*LN-107*/ 
/*LN-108*/         address[] memory markets = new address[](2);
/*LN-109*/ 
/*LN-110*/         for (uint256 i = 0; i < markets.length; i++) {
/*LN-111*/             address cToken = markets[i];
/*LN-112*/             uint256 borrowed = userBorrows[user][cToken];
/*LN-113*/ 
/*LN-114*/             if (borrowed > 0) {
/*LN-115*/                 uint256 price = oracle.getUnderlyingPrice(cToken);
/*LN-116*/                 uint256 value = (borrowed * price) / 1e18;
/*LN-117*/                 totalBorrows += value;
/*LN-118*/             }
/*LN-119*/         }
/*LN-120*/ 
/*LN-121*/         return totalBorrows;
/*LN-122*/     }
/*LN-123*/ 
/*LN-124*/ 
/*LN-125*/     function addMarket(address cToken, uint256 collateralFactor) external {
/*LN-126*/         supportedMarkets[cToken] = true;
/*LN-127*/         collateralFactors[cToken] = collateralFactor;
/*LN-128*/     }
/*LN-129*/ }
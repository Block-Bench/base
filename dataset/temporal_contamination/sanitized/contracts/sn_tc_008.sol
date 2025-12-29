/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IOracle {
/*LN-5*/     function getUnderlyingPrice(address cToken) external view returns (uint256);
/*LN-6*/ }
/*LN-7*/ 
/*LN-8*/ interface ICToken {
/*LN-9*/     function mint(uint256 mintAmount) external;
/*LN-10*/ 
/*LN-11*/     function borrow(uint256 borrowAmount) external;
/*LN-12*/ 
/*LN-13*/     function redeem(uint256 redeemTokens) external;
/*LN-14*/ 
/*LN-15*/     function underlying() external view returns (address);
/*LN-16*/ }
/*LN-17*/ 
/*LN-18*/ contract BasicLending {
/*LN-19*/     // Oracle for getting asset prices
/*LN-20*/     IOracle public oracle;
/*LN-21*/ 
/*LN-22*/     // Collateral factors (how much can be borrowed against collateral)
/*LN-23*/     mapping(address => uint256) public collateralFactors; // e.g., 75% = 0.75e18
/*LN-24*/ 
/*LN-25*/     // User deposits (crToken balances)
/*LN-26*/     mapping(address => mapping(address => uint256)) public userDeposits;
/*LN-27*/ 
/*LN-28*/     // User borrows
/*LN-29*/     mapping(address => mapping(address => uint256)) public userBorrows;
/*LN-30*/ 
/*LN-31*/     // Supported markets
/*LN-32*/     mapping(address => bool) public supportedMarkets;
/*LN-33*/ 
/*LN-34*/     event Deposit(address indexed user, address indexed cToken, uint256 amount);
/*LN-35*/     event Borrow(address indexed user, address indexed cToken, uint256 amount);
/*LN-36*/ 
/*LN-37*/     constructor(address _oracle) {
/*LN-38*/         oracle = IOracle(_oracle);
/*LN-39*/     }
/*LN-40*/ 
/*LN-41*/     function mint(address cToken, uint256 amount) external {
/*LN-42*/         require(supportedMarkets[cToken], "Market not supported");
/*LN-43*/ 
/*LN-44*/         // Transfer underlying from user (simplified)
/*LN-45*/         // address underlying = ICToken(cToken).underlying();
/*LN-46*/         // IERC20(underlying).transferFrom(msg.sender, address(this), amount);
/*LN-47*/ 
/*LN-48*/         // Mint crTokens to user
/*LN-49*/         userDeposits[msg.sender][cToken] += amount;
/*LN-50*/ 
/*LN-51*/         emit Deposit(msg.sender, cToken, amount);
/*LN-52*/     }
/*LN-53*/ 
/*LN-54*/     function borrow(address cToken, uint256 amount) external {
/*LN-55*/         require(supportedMarkets[cToken], "Market not supported");
/*LN-56*/ 
/*LN-57*/         // Calculate user's borrowing power
/*LN-58*/         uint256 borrowPower = calculateBorrowPower(msg.sender);
/*LN-59*/ 
/*LN-60*/         // Calculate current total borrows value
/*LN-61*/         uint256 currentBorrows = calculateTotalBorrows(msg.sender);
/*LN-62*/ 
/*LN-63*/         // Get value of new borrow
/*LN-64*/ 
/*LN-65*/         uint256 borrowValue = (oracle.getUnderlyingPrice(cToken) * amount) /
/*LN-66*/             1e18;
/*LN-67*/ 
/*LN-68*/         // Check if user has enough collateral
/*LN-69*/         require(
/*LN-70*/             currentBorrows + borrowValue <= borrowPower,
/*LN-71*/             "Insufficient collateral"
/*LN-72*/         );
/*LN-73*/ 
/*LN-74*/         // Update borrow balance
/*LN-75*/         userBorrows[msg.sender][cToken] += amount;
/*LN-76*/ 
/*LN-77*/         // Transfer tokens to borrower (simplified)
/*LN-78*/         // address underlying = ICToken(cToken).underlying();
/*LN-79*/         // IERC20(underlying).transfer(msg.sender, amount);
/*LN-80*/ 
/*LN-81*/         emit Borrow(msg.sender, cToken, amount);
/*LN-82*/     }
/*LN-83*/ 
/*LN-84*/     function calculateBorrowPower(address user) public view returns (uint256) {
/*LN-85*/         uint256 totalPower = 0;
/*LN-86*/ 
/*LN-87*/         // Iterate through all supported markets (simplified)
/*LN-88*/         // In reality, would track user's entered markets
/*LN-89*/         address[] memory markets = new address[](2); // Placeholder
/*LN-90*/ 
/*LN-91*/         for (uint256 i = 0; i < markets.length; i++) {
/*LN-92*/             address cToken = markets[i];
/*LN-93*/             uint256 balance = userDeposits[user][cToken];
/*LN-94*/ 
/*LN-95*/             if (balance > 0) {
/*LN-96*/                 // Get price from oracle
/*LN-97*/ 
/*LN-98*/                 uint256 price = oracle.getUnderlyingPrice(cToken);
/*LN-99*/ 
/*LN-100*/                 // Calculate value
/*LN-101*/                 uint256 value = (balance * price) / 1e18;
/*LN-102*/ 
/*LN-103*/                 // Apply collateral factor
/*LN-104*/                 uint256 power = (value * collateralFactors[cToken]) / 1e18;
/*LN-105*/ 
/*LN-106*/                 totalPower += power;
/*LN-107*/             }
/*LN-108*/         }
/*LN-109*/ 
/*LN-110*/         return totalPower;
/*LN-111*/     }
/*LN-112*/ 
/*LN-113*/     /**
/*LN-114*/      * @notice Calculate user's total borrow value
/*LN-115*/      * @param user The user address
/*LN-116*/      * @return Total borrow value in USD (scaled by 1e18)
/*LN-117*/      */
/*LN-118*/     function calculateTotalBorrows(address user) public view returns (uint256) {
/*LN-119*/         uint256 totalBorrows = 0;
/*LN-120*/ 
/*LN-121*/         // Iterate through all supported markets (simplified)
/*LN-122*/         address[] memory markets = new address[](2); // Placeholder
/*LN-123*/ 
/*LN-124*/         for (uint256 i = 0; i < markets.length; i++) {
/*LN-125*/             address cToken = markets[i];
/*LN-126*/             uint256 borrowed = userBorrows[user][cToken];
/*LN-127*/ 
/*LN-128*/             if (borrowed > 0) {
/*LN-129*/                 uint256 price = oracle.getUnderlyingPrice(cToken);
/*LN-130*/                 uint256 value = (borrowed * price) / 1e18;
/*LN-131*/                 totalBorrows += value;
/*LN-132*/             }
/*LN-133*/         }
/*LN-134*/ 
/*LN-135*/         return totalBorrows;
/*LN-136*/     }
/*LN-137*/ 
/*LN-138*/     /**
/*LN-139*/      * @notice Add a supported market
/*LN-140*/      * @param cToken The crToken to add
/*LN-141*/      * @param collateralFactor The collateral factor (e.g., 0.75e18 for 75%)
/*LN-142*/      */
/*LN-143*/     function addMarket(address cToken, uint256 collateralFactor) external {
/*LN-144*/         supportedMarkets[cToken] = true;
/*LN-145*/         collateralFactors[cToken] = collateralFactor;
/*LN-146*/     }
/*LN-147*/ }
/*LN-148*/ 
/*LN-149*/ 
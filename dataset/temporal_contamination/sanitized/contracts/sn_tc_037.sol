/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ /**
/*LN-5*/ 
/*LN-6*/  * Loss: $19.3 million
/*LN-7*/ 
/*LN-8*/  *
/*LN-9*/ 
/*LN-10*/  * causing the oracle to report incorrect prices, then borrowing against inflated collateral.
/*LN-11*/  */
/*LN-12*/ 
/*LN-13*/ interface IERC20 {
/*LN-14*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-15*/ 
/*LN-16*/     function transferFrom(
/*LN-17*/         address from,
/*LN-18*/         address to,
/*LN-19*/         uint256 amount
/*LN-20*/     ) external returns (bool);
/*LN-21*/ 
/*LN-22*/     function balanceOf(address account) external view returns (uint256);
/*LN-23*/ 
/*LN-24*/     function approve(address spender, uint256 amount) external returns (bool);
/*LN-25*/ }
/*LN-26*/ 
/*LN-27*/ interface IAaveOracle {
/*LN-28*/     function getAssetPrice(address asset) external view returns (uint256);
/*LN-29*/ 
/*LN-30*/     function setAssetSources(
/*LN-31*/         address[] calldata assets,
/*LN-32*/         address[] calldata sources
/*LN-33*/     ) external;
/*LN-34*/ }
/*LN-35*/ 
/*LN-36*/ interface IStablePool {
/*LN-37*/     function exchange(
/*LN-38*/         int128 i,
/*LN-39*/         int128 j,
/*LN-40*/         uint256 dx,
/*LN-41*/         uint256 min_dy
/*LN-42*/     ) external returns (uint256);
/*LN-43*/ 
/*LN-44*/     function get_dy(
/*LN-45*/         int128 i,
/*LN-46*/         int128 j,
/*LN-47*/         uint256 dx
/*LN-48*/     ) external view returns (uint256);
/*LN-49*/ 
/*LN-50*/     function balances(uint256 i) external view returns (uint256);
/*LN-51*/ }
/*LN-52*/ 
/*LN-53*/ interface ILendingPool {
/*LN-54*/     function deposit(
/*LN-55*/         address asset,
/*LN-56*/         uint256 amount,
/*LN-57*/         address onBehalfOf,
/*LN-58*/         uint16 referralCode
/*LN-59*/     ) external;
/*LN-60*/ 
/*LN-61*/     function borrow(
/*LN-62*/         address asset,
/*LN-63*/         uint256 amount,
/*LN-64*/         uint256 interestRateMode,
/*LN-65*/         uint16 referralCode,
/*LN-66*/         address onBehalfOf
/*LN-67*/     ) external;
/*LN-68*/ 
/*LN-69*/     function withdraw(
/*LN-70*/         address asset,
/*LN-71*/         uint256 amount,
/*LN-72*/         address to
/*LN-73*/     ) external returns (uint256);
/*LN-74*/ }
/*LN-75*/ 
/*LN-76*/ contract LendingPool is ILendingPool {
/*LN-77*/     IAaveOracle public oracle;
/*LN-78*/     mapping(address => uint256) public deposits;
/*LN-79*/     mapping(address => uint256) public borrows;
/*LN-80*/     uint256 public constant LTV = 8500;
/*LN-81*/     uint256 public constant BASIS_POINTS = 10000;
/*LN-82*/ 
/*LN-83*/     /**
/*LN-84*/      * @notice Deposit collateral into pool
/*LN-85*/      */
/*LN-86*/     function deposit(
/*LN-87*/         address asset,
/*LN-88*/         uint256 amount,
/*LN-89*/         address onBehalfOf,
/*LN-90*/         uint16 referralCode
/*LN-91*/     ) external override {
/*LN-92*/         IERC20(asset).transferFrom(msg.sender, address(this), amount);
/*LN-93*/         deposits[onBehalfOf] += amount;
/*LN-94*/     }
/*LN-95*/ 
/*LN-96*/     function borrow(
/*LN-97*/         address asset,
/*LN-98*/         uint256 amount,
/*LN-99*/         uint256 interestRateMode,
/*LN-100*/         uint16 referralCode,
/*LN-101*/         address onBehalfOf
/*LN-102*/     ) external override {
/*LN-103*/ 
/*LN-104*/         uint256 collateralPrice = oracle.getAssetPrice(msg.sender);
/*LN-105*/         uint256 borrowPrice = oracle.getAssetPrice(asset);
/*LN-106*/ 
/*LN-107*/         // No validation if price has changed dramatically
/*LN-108*/         // No circuit breaker for unusual price movements
/*LN-109*/ 
/*LN-110*/         uint256 collateralValue = (deposits[msg.sender] * collateralPrice) /
/*LN-111*/             1e18;
/*LN-112*/         uint256 maxBorrow = (collateralValue * LTV) / BASIS_POINTS;
/*LN-113*/ 
/*LN-114*/         uint256 borrowValue = (amount * borrowPrice) / 1e18;
/*LN-115*/ 
/*LN-116*/         require(borrowValue <= maxBorrow, "Insufficient collateral");
/*LN-117*/ 
/*LN-118*/         borrows[msg.sender] += amount;
/*LN-119*/         IERC20(asset).transfer(onBehalfOf, amount);
/*LN-120*/     }
/*LN-121*/ 
/*LN-122*/     /**
/*LN-123*/      * @notice Withdraw collateral
/*LN-124*/      */
/*LN-125*/     function withdraw(
/*LN-126*/         address asset,
/*LN-127*/         uint256 amount,
/*LN-128*/         address to
/*LN-129*/     ) external override returns (uint256) {
/*LN-130*/         require(deposits[msg.sender] >= amount, "Insufficient balance");
/*LN-131*/         deposits[msg.sender] -= amount;
/*LN-132*/         IERC20(asset).transfer(to, amount);
/*LN-133*/         return amount;
/*LN-134*/     }
/*LN-135*/ }
/*LN-136*/ 
/*LN-137*/ contract PoolOracle {
/*LN-138*/     IStablePool public stablePool;
/*LN-139*/ 
/*LN-140*/     constructor(address _pool) {
/*LN-141*/         stablePool = _pool;
/*LN-142*/     }
/*LN-143*/ 
/*LN-144*/     /**
/*LN-145*/ 
/*LN-146*/      */
/*LN-147*/     function getAssetPrice(address asset) external view returns (uint256) {
/*LN-148*/ 
/*LN-149*/         // No TWAP (Time-Weighted Average Price)
/*LN-150*/         // No external price validation
/*LN-151*/ 
/*LN-152*/         uint256 balance0 = stablePool.balances(0);
/*LN-153*/         uint256 balance1 = stablePool.balances(1);
/*LN-154*/ 
/*LN-155*/         // Easily manipulated by large swaps or liquidity removal
/*LN-156*/         uint256 price = (balance1 * 1e18) / balance0;
/*LN-157*/ 
/*LN-158*/         return price;
/*LN-159*/     }
/*LN-160*/ }
/*LN-161*/ 
/*LN-162*/ 
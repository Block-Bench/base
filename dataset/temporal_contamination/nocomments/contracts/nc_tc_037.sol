/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
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
/*LN-14*/ 
/*LN-15*/     function approve(address spender, uint256 amount) external returns (bool);
/*LN-16*/ }
/*LN-17*/ 
/*LN-18*/ interface IAaveOracle {
/*LN-19*/     function getAssetPrice(address asset) external view returns (uint256);
/*LN-20*/ 
/*LN-21*/     function setAssetSources(
/*LN-22*/         address[] calldata assets,
/*LN-23*/         address[] calldata sources
/*LN-24*/     ) external;
/*LN-25*/ }
/*LN-26*/ 
/*LN-27*/ interface IStablePool {
/*LN-28*/     function exchange(
/*LN-29*/         int128 i,
/*LN-30*/         int128 j,
/*LN-31*/         uint256 dx,
/*LN-32*/         uint256 min_dy
/*LN-33*/     ) external returns (uint256);
/*LN-34*/ 
/*LN-35*/     function get_dy(
/*LN-36*/         int128 i,
/*LN-37*/         int128 j,
/*LN-38*/         uint256 dx
/*LN-39*/     ) external view returns (uint256);
/*LN-40*/ 
/*LN-41*/     function balances(uint256 i) external view returns (uint256);
/*LN-42*/ }
/*LN-43*/ 
/*LN-44*/ interface ILendingPool {
/*LN-45*/     function deposit(
/*LN-46*/         address asset,
/*LN-47*/         uint256 amount,
/*LN-48*/         address onBehalfOf,
/*LN-49*/         uint16 referralCode
/*LN-50*/     ) external;
/*LN-51*/ 
/*LN-52*/     function borrow(
/*LN-53*/         address asset,
/*LN-54*/         uint256 amount,
/*LN-55*/         uint256 interestRateMode,
/*LN-56*/         uint16 referralCode,
/*LN-57*/         address onBehalfOf
/*LN-58*/     ) external;
/*LN-59*/ 
/*LN-60*/     function withdraw(
/*LN-61*/         address asset,
/*LN-62*/         uint256 amount,
/*LN-63*/         address to
/*LN-64*/     ) external returns (uint256);
/*LN-65*/ }
/*LN-66*/ 
/*LN-67*/ contract LendingPool is ILendingPool {
/*LN-68*/     IAaveOracle public oracle;
/*LN-69*/     mapping(address => uint256) public deposits;
/*LN-70*/     mapping(address => uint256) public borrows;
/*LN-71*/     uint256 public constant LTV = 8500;
/*LN-72*/     uint256 public constant BASIS_POINTS = 10000;
/*LN-73*/ 
/*LN-74*/ 
/*LN-75*/     function deposit(
/*LN-76*/         address asset,
/*LN-77*/         uint256 amount,
/*LN-78*/         address onBehalfOf,
/*LN-79*/         uint16 referralCode
/*LN-80*/     ) external override {
/*LN-81*/         IERC20(asset).transferFrom(msg.sender, address(this), amount);
/*LN-82*/         deposits[onBehalfOf] += amount;
/*LN-83*/     }
/*LN-84*/ 
/*LN-85*/     function borrow(
/*LN-86*/         address asset,
/*LN-87*/         uint256 amount,
/*LN-88*/         uint256 interestRateMode,
/*LN-89*/         uint16 referralCode,
/*LN-90*/         address onBehalfOf
/*LN-91*/     ) external override {
/*LN-92*/ 
/*LN-93*/         uint256 collateralPrice = oracle.getAssetPrice(msg.sender);
/*LN-94*/         uint256 borrowPrice = oracle.getAssetPrice(asset);
/*LN-95*/ 
/*LN-96*/ 
/*LN-97*/         uint256 collateralValue = (deposits[msg.sender] * collateralPrice) /
/*LN-98*/             1e18;
/*LN-99*/         uint256 maxBorrow = (collateralValue * LTV) / BASIS_POINTS;
/*LN-100*/ 
/*LN-101*/         uint256 borrowValue = (amount * borrowPrice) / 1e18;
/*LN-102*/ 
/*LN-103*/         require(borrowValue <= maxBorrow, "Insufficient collateral");
/*LN-104*/ 
/*LN-105*/         borrows[msg.sender] += amount;
/*LN-106*/         IERC20(asset).transfer(onBehalfOf, amount);
/*LN-107*/     }
/*LN-108*/ 
/*LN-109*/ 
/*LN-110*/     function withdraw(
/*LN-111*/         address asset,
/*LN-112*/         uint256 amount,
/*LN-113*/         address to
/*LN-114*/     ) external override returns (uint256) {
/*LN-115*/         require(deposits[msg.sender] >= amount, "Insufficient balance");
/*LN-116*/         deposits[msg.sender] -= amount;
/*LN-117*/         IERC20(asset).transfer(to, amount);
/*LN-118*/         return amount;
/*LN-119*/     }
/*LN-120*/ }
/*LN-121*/ 
/*LN-122*/ contract PoolOracle {
/*LN-123*/     IStablePool public stablePool;
/*LN-124*/ 
/*LN-125*/     constructor(address _pool) {
/*LN-126*/         stablePool = _pool;
/*LN-127*/     }
/*LN-128*/ 
/*LN-129*/ 
/*LN-130*/     function getAssetPrice(address asset) external view returns (uint256) {
/*LN-131*/ 
/*LN-132*/ 
/*LN-133*/         uint256 balance0 = stablePool.balances(0);
/*LN-134*/         uint256 balance1 = stablePool.balances(1);
/*LN-135*/ 
/*LN-136*/ 
/*LN-137*/         uint256 price = (balance1 * 1e18) / balance0;
/*LN-138*/ 
/*LN-139*/         return price;
/*LN-140*/     }
/*LN-141*/ }
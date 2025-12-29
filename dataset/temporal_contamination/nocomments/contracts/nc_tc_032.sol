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
/*LN-17*/ interface IFlashLoanReceiver {
/*LN-18*/     function executeOperation(
/*LN-19*/         address[] calldata assets,
/*LN-20*/         uint256[] calldata amounts,
/*LN-21*/         uint256[] calldata premiums,
/*LN-22*/         address initiator,
/*LN-23*/         bytes calldata params
/*LN-24*/     ) external returns (bool);
/*LN-25*/ }
/*LN-26*/ 
/*LN-27*/ contract CrossLendingPool {
/*LN-28*/     uint256 public constant RAY = 1e27;
/*LN-29*/ 
/*LN-30*/     struct ReserveData {
/*LN-31*/         uint256 liquidityIndex;
/*LN-32*/         uint256 totalLiquidity;
/*LN-33*/         address rTokenAddress;
/*LN-34*/     }
/*LN-35*/ 
/*LN-36*/     mapping(address => ReserveData) public reserves;
/*LN-37*/ 
/*LN-38*/     function deposit(
/*LN-39*/         address asset,
/*LN-40*/         uint256 amount,
/*LN-41*/         address onBehalfOf,
/*LN-42*/         uint16 referralCode
/*LN-43*/     ) external {
/*LN-44*/         IERC20(asset).transferFrom(msg.sender, address(this), amount);
/*LN-45*/ 
/*LN-46*/         ReserveData storage reserve = reserves[asset];
/*LN-47*/ 
/*LN-48*/         uint256 currentLiquidityIndex = reserve.liquidityIndex;
/*LN-49*/         if (currentLiquidityIndex == 0) {
/*LN-50*/             currentLiquidityIndex = RAY;
/*LN-51*/         }
/*LN-52*/ 
/*LN-53*/ 
/*LN-54*/         reserve.liquidityIndex =
/*LN-55*/             currentLiquidityIndex +
/*LN-56*/             (amount * RAY) /
/*LN-57*/             (reserve.totalLiquidity + 1);
/*LN-58*/         reserve.totalLiquidity += amount;
/*LN-59*/ 
/*LN-60*/ 
/*LN-61*/         uint256 rTokenAmount = rayDiv(amount, reserve.liquidityIndex);
/*LN-62*/         _mintRToken(reserve.rTokenAddress, onBehalfOf, rTokenAmount);
/*LN-63*/     }
/*LN-64*/ 
/*LN-65*/     function withdraw(
/*LN-66*/         address asset,
/*LN-67*/         uint256 amount,
/*LN-68*/         address to
/*LN-69*/     ) external returns (uint256) {
/*LN-70*/         ReserveData storage reserve = reserves[asset];
/*LN-71*/ 
/*LN-72*/ 
/*LN-73*/         uint256 rTokensToBurn = rayDiv(amount, reserve.liquidityIndex);
/*LN-74*/ 
/*LN-75*/         _burnRToken(reserve.rTokenAddress, msg.sender, rTokensToBurn);
/*LN-76*/ 
/*LN-77*/         reserve.totalLiquidity -= amount;
/*LN-78*/         IERC20(asset).transfer(to, amount);
/*LN-79*/ 
/*LN-80*/         return amount;
/*LN-81*/     }
/*LN-82*/ 
/*LN-83*/ 
/*LN-84*/     function borrow(
/*LN-85*/         address asset,
/*LN-86*/         uint256 amount,
/*LN-87*/         uint256 interestRateMode,
/*LN-88*/         uint16 referralCode,
/*LN-89*/         address onBehalfOf
/*LN-90*/     ) external {
/*LN-91*/ 
/*LN-92*/         IERC20(asset).transfer(onBehalfOf, amount);
/*LN-93*/     }
/*LN-94*/ 
/*LN-95*/     function flashLoan(
/*LN-96*/         address receiverAddress,
/*LN-97*/         address[] calldata assets,
/*LN-98*/         uint256[] calldata amounts,
/*LN-99*/         uint256[] calldata modes,
/*LN-100*/         address onBehalfOf,
/*LN-101*/         bytes calldata params,
/*LN-102*/         uint16 referralCode
/*LN-103*/     ) external {
/*LN-104*/         for (uint256 i = 0; i < assets.length; i++) {
/*LN-105*/             IERC20(assets[i]).transfer(receiverAddress, amounts[i]);
/*LN-106*/         }
/*LN-107*/ 
/*LN-108*/ 
/*LN-109*/         require(
/*LN-110*/             IFlashLoanReceiver(receiverAddress).executeOperation(
/*LN-111*/                 assets,
/*LN-112*/                 amounts,
/*LN-113*/                 new uint256[](assets.length),
/*LN-114*/                 msg.sender,
/*LN-115*/                 params
/*LN-116*/             ),
/*LN-117*/             "Flashloan callback failed"
/*LN-118*/         );
/*LN-119*/ 
/*LN-120*/ 
/*LN-121*/         for (uint256 i = 0; i < assets.length; i++) {
/*LN-122*/             IERC20(assets[i]).transferFrom(
/*LN-123*/                 receiverAddress,
/*LN-124*/                 address(this),
/*LN-125*/                 amounts[i]
/*LN-126*/             );
/*LN-127*/         }
/*LN-128*/     }
/*LN-129*/ 
/*LN-130*/     function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
/*LN-131*/         uint256 halfB = b / 2;
/*LN-132*/         require(b != 0, "Division by zero");
/*LN-133*/         return (a * RAY + halfB) / b;
/*LN-134*/     }
/*LN-135*/ 
/*LN-136*/     function _mintRToken(address rToken, address to, uint256 amount) internal {
/*LN-137*/ 
/*LN-138*/     }
/*LN-139*/ 
/*LN-140*/     function _burnRToken(
/*LN-141*/         address rToken,
/*LN-142*/         address from,
/*LN-143*/         uint256 amount
/*LN-144*/     ) internal {
/*LN-145*/ 
/*LN-146*/     }
/*LN-147*/ }
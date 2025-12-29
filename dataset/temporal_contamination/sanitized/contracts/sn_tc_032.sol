/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
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
/*LN-18*/ interface IFlashLoanReceiver {
/*LN-19*/     function executeOperation(
/*LN-20*/         address[] calldata assets,
/*LN-21*/         uint256[] calldata amounts,
/*LN-22*/         uint256[] calldata premiums,
/*LN-23*/         address initiator,
/*LN-24*/         bytes calldata params
/*LN-25*/     ) external returns (bool);
/*LN-26*/ }
/*LN-27*/ 
/*LN-28*/ contract CrossLendingPool {
/*LN-29*/     uint256 public constant RAY = 1e27;
/*LN-30*/ 
/*LN-31*/     struct ReserveData {
/*LN-32*/         uint256 liquidityIndex;
/*LN-33*/         uint256 totalLiquidity;
/*LN-34*/         address rTokenAddress;
/*LN-35*/     }
/*LN-36*/ 
/*LN-37*/     mapping(address => ReserveData) public reserves;
/*LN-38*/ 
/*LN-39*/     function deposit(
/*LN-40*/         address asset,
/*LN-41*/         uint256 amount,
/*LN-42*/         address onBehalfOf,
/*LN-43*/         uint16 referralCode
/*LN-44*/     ) external {
/*LN-45*/         IERC20(asset).transferFrom(msg.sender, address(this), amount);
/*LN-46*/ 
/*LN-47*/         ReserveData storage reserve = reserves[asset];
/*LN-48*/ 
/*LN-49*/         uint256 currentLiquidityIndex = reserve.liquidityIndex;
/*LN-50*/         if (currentLiquidityIndex == 0) {
/*LN-51*/             currentLiquidityIndex = RAY;
/*LN-52*/         }
/*LN-53*/ 
/*LN-54*/         // Update index (simplified)
/*LN-55*/         reserve.liquidityIndex =
/*LN-56*/             currentLiquidityIndex +
/*LN-57*/             (amount * RAY) /
/*LN-58*/             (reserve.totalLiquidity + 1);
/*LN-59*/         reserve.totalLiquidity += amount;
/*LN-60*/ 
/*LN-61*/         // Mint rTokens to user
/*LN-62*/         uint256 rTokenAmount = rayDiv(amount, reserve.liquidityIndex);
/*LN-63*/         _mintRToken(reserve.rTokenAddress, onBehalfOf, rTokenAmount);
/*LN-64*/     }
/*LN-65*/ 
/*LN-66*/     function withdraw(
/*LN-67*/         address asset,
/*LN-68*/         uint256 amount,
/*LN-69*/         address to
/*LN-70*/     ) external returns (uint256) {
/*LN-71*/         ReserveData storage reserve = reserves[asset];
/*LN-72*/ 
/*LN-73*/         // rayDiv rounding errors become significant
/*LN-74*/         // User can burn fewer rTokens than they should need
/*LN-75*/         uint256 rTokensToBurn = rayDiv(amount, reserve.liquidityIndex);
/*LN-76*/ 
/*LN-77*/         _burnRToken(reserve.rTokenAddress, msg.sender, rTokensToBurn);
/*LN-78*/ 
/*LN-79*/         reserve.totalLiquidity -= amount;
/*LN-80*/         IERC20(asset).transfer(to, amount);
/*LN-81*/ 
/*LN-82*/         return amount;
/*LN-83*/     }
/*LN-84*/ 
/*LN-85*/     /**
/*LN-86*/      * @notice Borrow tokens from pool with collateral
/*LN-87*/      */
/*LN-88*/     function borrow(
/*LN-89*/         address asset,
/*LN-90*/         uint256 amount,
/*LN-91*/         uint256 interestRateMode,
/*LN-92*/         uint16 referralCode,
/*LN-93*/         address onBehalfOf
/*LN-94*/     ) external {
/*LN-95*/         // Simplified borrow logic
/*LN-96*/         IERC20(asset).transfer(onBehalfOf, amount);
/*LN-97*/     }
/*LN-98*/ 
/*LN-99*/     function flashLoan(
/*LN-100*/         address receiverAddress,
/*LN-101*/         address[] calldata assets,
/*LN-102*/         uint256[] calldata amounts,
/*LN-103*/         uint256[] calldata modes,
/*LN-104*/         address onBehalfOf,
/*LN-105*/         bytes calldata params,
/*LN-106*/         uint16 referralCode
/*LN-107*/     ) external {
/*LN-108*/         for (uint256 i = 0; i < assets.length; i++) {
/*LN-109*/             IERC20(assets[i]).transfer(receiverAddress, amounts[i]);
/*LN-110*/         }
/*LN-111*/ 
/*LN-112*/         // Call receiver callback
/*LN-113*/         require(
/*LN-114*/             IFlashLoanReceiver(receiverAddress).executeOperation(
/*LN-115*/                 assets,
/*LN-116*/                 amounts,
/*LN-117*/                 new uint256[](assets.length),
/*LN-118*/                 msg.sender,
/*LN-119*/                 params
/*LN-120*/             ),
/*LN-121*/             "Flashloan callback failed"
/*LN-122*/         );
/*LN-123*/ 
/*LN-124*/         // Each cycle slightly increases liquidityIndex
/*LN-125*/ 
/*LN-126*/         for (uint256 i = 0; i < assets.length; i++) {
/*LN-127*/             IERC20(assets[i]).transferFrom(
/*LN-128*/                 receiverAddress,
/*LN-129*/                 address(this),
/*LN-130*/                 amounts[i]
/*LN-131*/             );
/*LN-132*/         }
/*LN-133*/     }
/*LN-134*/ 
/*LN-135*/     function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
/*LN-136*/         uint256 halfB = b / 2;
/*LN-137*/         require(b != 0, "Division by zero");
/*LN-138*/         return (a * RAY + halfB) / b;
/*LN-139*/     }
/*LN-140*/ 
/*LN-141*/     function _mintRToken(address rToken, address to, uint256 amount) internal {
/*LN-142*/         // Simplified mint
/*LN-143*/     }
/*LN-144*/ 
/*LN-145*/     function _burnRToken(
/*LN-146*/         address rToken,
/*LN-147*/         address from,
/*LN-148*/         uint256 amount
/*LN-149*/     ) internal {
/*LN-150*/         // Simplified burn
/*LN-151*/     }
/*LN-152*/ }
/*LN-153*/ 
/*LN-154*/ 
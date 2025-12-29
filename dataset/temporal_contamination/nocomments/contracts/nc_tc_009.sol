/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ contract BasicSwapPool {
/*LN-4*/ 
/*LN-5*/     address public token0;
/*LN-6*/     address public token1;
/*LN-7*/ 
/*LN-8*/ 
/*LN-9*/     uint160 public sqrtPriceX96;
/*LN-10*/     int24 public currentTick;
/*LN-11*/     uint128 public liquidity;
/*LN-12*/ 
/*LN-13*/ 
/*LN-14*/     mapping(int24 => int128) public liquidityNet;
/*LN-15*/ 
/*LN-16*/ 
/*LN-17*/     struct Position {
/*LN-18*/         uint128 liquidity;
/*LN-19*/         int24 tickLower;
/*LN-20*/         int24 tickUpper;
/*LN-21*/     }
/*LN-22*/ 
/*LN-23*/     mapping(bytes32 => Position) public positions;
/*LN-24*/ 
/*LN-25*/     event Swap(
/*LN-26*/         address indexed sender,
/*LN-27*/         uint256 amount0In,
/*LN-28*/         uint256 amount1In,
/*LN-29*/         uint256 amount0Out,
/*LN-30*/         uint256 amount1Out
/*LN-31*/     );
/*LN-32*/ 
/*LN-33*/     event LiquidityAdded(
/*LN-34*/         address indexed provider,
/*LN-35*/         int24 tickLower,
/*LN-36*/         int24 tickUpper,
/*LN-37*/         uint128 liquidity
/*LN-38*/     );
/*LN-39*/ 
/*LN-40*/ 
/*LN-41*/     function addLiquidity(
/*LN-42*/         int24 tickLower,
/*LN-43*/         int24 tickUpper,
/*LN-44*/         uint128 liquidityDelta
/*LN-45*/     ) external returns (uint256 amount0, uint256 amount1) {
/*LN-46*/         require(tickLower < tickUpper, "Invalid ticks");
/*LN-47*/         require(liquidityDelta > 0, "Zero liquidity");
/*LN-48*/ 
/*LN-49*/ 
/*LN-50*/         bytes32 positionKey = keccak256(
/*LN-51*/             abi.encodePacked(msg.sender, tickLower, tickUpper)
/*LN-52*/         );
/*LN-53*/ 
/*LN-54*/ 
/*LN-55*/         Position storage position = positions[positionKey];
/*LN-56*/         position.liquidity += liquidityDelta;
/*LN-57*/         position.tickLower = tickLower;
/*LN-58*/         position.tickUpper = tickUpper;
/*LN-59*/ 
/*LN-60*/ 
/*LN-61*/         liquidityNet[tickLower] += int128(liquidityDelta);
/*LN-62*/         liquidityNet[tickUpper] -= int128(liquidityDelta);
/*LN-63*/ 
/*LN-64*/ 
/*LN-65*/         if (currentTick >= tickLower && currentTick < tickUpper) {
/*LN-66*/             liquidity += liquidityDelta;
/*LN-67*/         }
/*LN-68*/ 
/*LN-69*/ 
/*LN-70*/         (amount0, amount1) = _calculateAmounts(
/*LN-71*/             sqrtPriceX96,
/*LN-72*/             tickLower,
/*LN-73*/             tickUpper,
/*LN-74*/             int128(liquidityDelta)
/*LN-75*/         );
/*LN-76*/ 
/*LN-77*/         emit LiquidityAdded(msg.sender, tickLower, tickUpper, liquidityDelta);
/*LN-78*/     }
/*LN-79*/ 
/*LN-80*/     function swap(
/*LN-81*/         bool zeroForOne,
/*LN-82*/         int256 amountSpecified,
/*LN-83*/         uint160 sqrtPriceLimitX96
/*LN-84*/     ) external returns (int256 amount0, int256 amount1) {
/*LN-85*/         require(amountSpecified != 0, "Zero amount");
/*LN-86*/ 
/*LN-87*/ 
/*LN-88*/         uint160 sqrtPriceX96Next = sqrtPriceX96;
/*LN-89*/         uint128 liquidityNext = liquidity;
/*LN-90*/         int24 tickNext = currentTick;
/*LN-91*/ 
/*LN-92*/ 
/*LN-93*/         while (amountSpecified != 0) {
/*LN-94*/ 
/*LN-95*/             (
/*LN-96*/                 uint256 amountIn,
/*LN-97*/                 uint256 amountOut,
/*LN-98*/                 uint160 sqrtPriceX96Target
/*LN-99*/             ) = _computeSwapStep(
/*LN-100*/                     sqrtPriceX96Next,
/*LN-101*/                     sqrtPriceLimitX96,
/*LN-102*/                     liquidityNext,
/*LN-103*/                     amountSpecified
/*LN-104*/                 );
/*LN-105*/ 
/*LN-106*/ 
/*LN-107*/             sqrtPriceX96Next = sqrtPriceX96Target;
/*LN-108*/ 
/*LN-109*/ 
/*LN-110*/             int24 tickCrossed = _getTickAtSqrtRatio(sqrtPriceX96Next);
/*LN-111*/             if (tickCrossed != tickNext) {
/*LN-112*/ 
/*LN-113*/ 
/*LN-114*/                 int128 liquidityNetAtTick = liquidityNet[tickCrossed];
/*LN-115*/ 
/*LN-116*/                 if (zeroForOne) {
/*LN-117*/                     liquidityNetAtTick = -liquidityNetAtTick;
/*LN-118*/                 }
/*LN-119*/ 
/*LN-120*/                 liquidityNext = _addLiquidity(
/*LN-121*/                     liquidityNext,
/*LN-122*/                     liquidityNetAtTick
/*LN-123*/                 );
/*LN-124*/ 
/*LN-125*/                 tickNext = tickCrossed;
/*LN-126*/             }
/*LN-127*/ 
/*LN-128*/ 
/*LN-129*/             if (amountSpecified > 0) {
/*LN-130*/                 amountSpecified -= int256(amountIn);
/*LN-131*/             } else {
/*LN-132*/                 amountSpecified += int256(amountOut);
/*LN-133*/             }
/*LN-134*/         }
/*LN-135*/ 
/*LN-136*/ 
/*LN-137*/         sqrtPriceX96 = sqrtPriceX96Next;
/*LN-138*/         liquidity = liquidityNext;
/*LN-139*/         currentTick = tickNext;
/*LN-140*/ 
/*LN-141*/         return (amount0, amount1);
/*LN-142*/     }
/*LN-143*/ 
/*LN-144*/     function _addLiquidity(
/*LN-145*/         uint128 x,
/*LN-146*/         int128 y
/*LN-147*/     ) internal pure returns (uint128 z) {
/*LN-148*/         if (y < 0) {
/*LN-149*/ 
/*LN-150*/             z = x - uint128(-y);
/*LN-151*/         } else {
/*LN-152*/ 
/*LN-153*/             z = x + uint128(y);
/*LN-154*/         }
/*LN-155*/ 
/*LN-156*/     }
/*LN-157*/ 
/*LN-158*/ 
/*LN-159*/     function _calculateAmounts(
/*LN-160*/         uint160 sqrtPrice,
/*LN-161*/         int24 tickLower,
/*LN-162*/         int24 tickUpper,
/*LN-163*/         int128 liquidityDelta
/*LN-164*/     ) internal pure returns (uint256 amount0, uint256 amount1) {
/*LN-165*/ 
/*LN-166*/ 
/*LN-167*/         amount0 = uint256(uint128(liquidityDelta)) / 2;
/*LN-168*/         amount1 = uint256(uint128(liquidityDelta)) / 2;
/*LN-169*/     }
/*LN-170*/ 
/*LN-171*/ 
/*LN-172*/     function _computeSwapStep(
/*LN-173*/         uint160 sqrtPriceCurrentX96,
/*LN-174*/         uint160 sqrtPriceTargetX96,
/*LN-175*/         uint128 liquidityCurrent,
/*LN-176*/         int256 amountRemaining
/*LN-177*/     )
/*LN-178*/         internal
/*LN-179*/         pure
/*LN-180*/         returns (uint256 amountIn, uint256 amountOut, uint160 sqrtPriceNextX96)
/*LN-181*/     {
/*LN-182*/ 
/*LN-183*/         amountIn =
/*LN-184*/             uint256(amountRemaining > 0 ? amountRemaining : -amountRemaining) /
/*LN-185*/             2;
/*LN-186*/         amountOut = amountIn;
/*LN-187*/         sqrtPriceNextX96 = sqrtPriceCurrentX96;
/*LN-188*/     }
/*LN-189*/ 
/*LN-190*/ 
/*LN-191*/     function _getTickAtSqrtRatio(
/*LN-192*/         uint160 sqrtPriceX96
/*LN-193*/     ) internal pure returns (int24 tick) {
/*LN-194*/ 
/*LN-195*/         return int24(int256(uint256(sqrtPriceX96 >> 96)));
/*LN-196*/     }
/*LN-197*/ }
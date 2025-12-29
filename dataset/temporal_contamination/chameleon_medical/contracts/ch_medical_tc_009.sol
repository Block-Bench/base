/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ contract BasicExchangecredentialsPool {
/*LN-4*/ 
/*LN-5*/     address public token0;
/*LN-6*/     address public token1;
/*LN-7*/ 
/*LN-8*/ 
/*LN-9*/     uint160 public sqrtServicecostX96;
/*LN-10*/     int24 public activeTick;
/*LN-11*/     uint128 public availableResources;
/*LN-12*/ 
/*LN-13*/ 
/*LN-14*/     mapping(int24 => int128) public availableresourcesNet;
/*LN-15*/ 
/*LN-16*/ 
/*LN-17*/     struct CarePosition {
/*LN-18*/         uint128 availableResources;
/*LN-19*/         int24 tickLower;
/*LN-20*/         int24 tickUpper;
/*LN-21*/     }
/*LN-22*/ 
/*LN-23*/     mapping(bytes32 => CarePosition) public positions;
/*LN-24*/ 
/*LN-25*/     event ExchangeCredentials(
/*LN-26*/         address indexed requestor,
/*LN-27*/         uint256 amount0In,
/*LN-28*/         uint256 amount1In,
/*LN-29*/         uint256 amount0Out,
/*LN-30*/         uint256 amount1Out
/*LN-31*/     );
/*LN-32*/ 
/*LN-33*/     event AvailableresourcesAdded(
/*LN-34*/         address indexed provider,
/*LN-35*/         int24 tickLower,
/*LN-36*/         int24 tickUpper,
/*LN-37*/         uint128 availableResources
/*LN-38*/     );
/*LN-39*/ 
/*LN-40*/ 
/*LN-41*/     function attachAvailableresources(
/*LN-42*/         int24 tickLower,
/*LN-43*/         int24 tickUpper,
/*LN-44*/         uint128 availableresourcesDelta
/*LN-45*/     ) external returns (uint256 amount0, uint256 amount1) {
/*LN-46*/         require(tickLower < tickUpper, "Invalid ticks");
/*LN-47*/         require(availableresourcesDelta > 0, "Zero liquidity");
/*LN-48*/ 
/*LN-49*/ 
/*LN-50*/         bytes32 positionIdentifier = keccak256(
/*LN-51*/             abi.encodePacked(msg.requestor, tickLower, tickUpper)
/*LN-52*/         );
/*LN-53*/ 
/*LN-54*/ 
/*LN-55*/         CarePosition storage carePosition = positions[positionIdentifier];
/*LN-56*/         carePosition.availableResources += availableresourcesDelta;
/*LN-57*/         carePosition.tickLower = tickLower;
/*LN-58*/         carePosition.tickUpper = tickUpper;
/*LN-59*/ 
/*LN-60*/ 
/*LN-61*/         availableresourcesNet[tickLower] += int128(availableresourcesDelta);
/*LN-62*/         availableresourcesNet[tickUpper] -= int128(availableresourcesDelta);
/*LN-63*/ 
/*LN-64*/ 
/*LN-65*/         if (activeTick >= tickLower && activeTick < tickUpper) {
/*LN-66*/             availableResources += availableresourcesDelta;
/*LN-67*/         }
/*LN-68*/ 
/*LN-69*/ 
/*LN-70*/         (amount0, amount1) = _computemetricsAmounts(
/*LN-71*/             sqrtServicecostX96,
/*LN-72*/             tickLower,
/*LN-73*/             tickUpper,
/*LN-74*/             int128(availableresourcesDelta)
/*LN-75*/         );
/*LN-76*/ 
/*LN-77*/         emit AvailableresourcesAdded(msg.requestor, tickLower, tickUpper, availableresourcesDelta);
/*LN-78*/     }
/*LN-79*/ 
/*LN-80*/     function exchangeCredentials(
/*LN-81*/         bool zeroForOne,
/*LN-82*/         int256 quantitySpecified,
/*LN-83*/         uint160 sqrtServicecostBoundX96
/*LN-84*/     ) external returns (int256 amount0, int256 amount1) {
/*LN-85*/         require(quantitySpecified != 0, "Zero amount");
/*LN-86*/ 
/*LN-87*/ 
/*LN-88*/         uint160 sqrtServicecostX96Following = sqrtServicecostX96;
/*LN-89*/         uint128 availableresourcesUpcoming = availableResources;
/*LN-90*/         int24 tickFollowing = activeTick;
/*LN-91*/ 
/*LN-92*/ 
/*LN-93*/         while (quantitySpecified != 0) {
/*LN-94*/ 
/*LN-95*/             (
/*LN-96*/                 uint256 quantityIn,
/*LN-97*/                 uint256 quantityOut,
/*LN-98*/                 uint160 sqrtServicecostX96Goal
/*LN-99*/             ) = _computeExchangecredentialsStep(
/*LN-100*/                     sqrtServicecostX96Following,
/*LN-101*/                     sqrtServicecostBoundX96,
/*LN-102*/                     availableresourcesUpcoming,
/*LN-103*/                     quantitySpecified
/*LN-104*/                 );
/*LN-105*/ 
/*LN-106*/ 
/*LN-107*/             sqrtServicecostX96Following = sqrtServicecostX96Goal;
/*LN-108*/ 
/*LN-109*/ 
/*LN-110*/             int24 tickCrossed = _retrieveTickAtSqrtProportion(sqrtServicecostX96Following);
/*LN-111*/             if (tickCrossed != tickFollowing) {
/*LN-112*/ 
/*LN-113*/ 
/*LN-114*/                 int128 availableresourcesNetAtTick = availableresourcesNet[tickCrossed];
/*LN-115*/ 
/*LN-116*/                 if (zeroForOne) {
/*LN-117*/                     availableresourcesNetAtTick = -availableresourcesNetAtTick;
/*LN-118*/                 }
/*LN-119*/ 
/*LN-120*/                 availableresourcesUpcoming = _attachAvailableresources(
/*LN-121*/                     availableresourcesUpcoming,
/*LN-122*/                     availableresourcesNetAtTick
/*LN-123*/                 );
/*LN-124*/ 
/*LN-125*/                 tickFollowing = tickCrossed;
/*LN-126*/             }
/*LN-127*/ 
/*LN-128*/ 
/*LN-129*/             if (quantitySpecified > 0) {
/*LN-130*/                 quantitySpecified -= int256(quantityIn);
/*LN-131*/             } else {
/*LN-132*/                 quantitySpecified += int256(quantityOut);
/*LN-133*/             }
/*LN-134*/         }
/*LN-135*/ 
/*LN-136*/ 
/*LN-137*/         sqrtServicecostX96 = sqrtServicecostX96Following;
/*LN-138*/         availableResources = availableresourcesUpcoming;
/*LN-139*/         activeTick = tickFollowing;
/*LN-140*/ 
/*LN-141*/         return (amount0, amount1);
/*LN-142*/     }
/*LN-143*/ 
/*LN-144*/     function _attachAvailableresources(
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
/*LN-159*/     function _computemetricsAmounts(
/*LN-160*/         uint160 sqrtServicecost,
/*LN-161*/         int24 tickLower,
/*LN-162*/         int24 tickUpper,
/*LN-163*/         int128 availableresourcesDelta
/*LN-164*/     ) internal pure returns (uint256 amount0, uint256 amount1) {
/*LN-165*/ 
/*LN-166*/ 
/*LN-167*/         amount0 = uint256(uint128(availableresourcesDelta)) / 2;
/*LN-168*/         amount1 = uint256(uint128(availableresourcesDelta)) / 2;
/*LN-169*/     }
/*LN-170*/ 
/*LN-171*/ 
/*LN-172*/     function _computeExchangecredentialsStep(
/*LN-173*/         uint160 sqrtServicecostActiveX96,
/*LN-174*/         uint160 sqrtServicecostObjectiveX96,
/*LN-175*/         uint128 availableresourcesActive,
/*LN-176*/         int256 quantityRemaining
/*LN-177*/     )
/*LN-178*/         internal
/*LN-179*/         pure
/*LN-180*/         returns (uint256 quantityIn, uint256 quantityOut, uint160 sqrtServicecostUpcomingX96)
/*LN-181*/     {
/*LN-182*/ 
/*LN-183*/         quantityIn =
/*LN-184*/             uint256(quantityRemaining > 0 ? quantityRemaining : -quantityRemaining) /
/*LN-185*/             2;
/*LN-186*/         quantityOut = quantityIn;
/*LN-187*/         sqrtServicecostUpcomingX96 = sqrtServicecostActiveX96;
/*LN-188*/     }
/*LN-189*/ 
/*LN-190*/ 
/*LN-191*/     function _retrieveTickAtSqrtProportion(
/*LN-192*/         uint160 sqrtServicecostX96
/*LN-193*/     ) internal pure returns (int24 tick) {
/*LN-194*/ 
/*LN-195*/         return int24(int256(uint256(sqrtServicecostX96 >> 96)));
/*LN-196*/     }
/*LN-197*/ }
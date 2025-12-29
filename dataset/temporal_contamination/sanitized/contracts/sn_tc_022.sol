/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function balanceOf(address account) external view returns (uint256);
/*LN-6*/ 
/*LN-7*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-8*/ 
/*LN-9*/     function transferFrom(
/*LN-10*/         address from,
/*LN-11*/         address to,
/*LN-12*/         uint256 amount
/*LN-13*/     ) external returns (bool);
/*LN-14*/ }
/*LN-15*/ 
/*LN-16*/ contract SwapPair {
/*LN-17*/     address public token0;
/*LN-18*/     address public token1;
/*LN-19*/ 
/*LN-20*/     uint112 private reserve0;
/*LN-21*/     uint112 private reserve1;
/*LN-22*/ 
/*LN-23*/     uint256 public constant TOTAL_FEE = 16; // 0.16% fee
/*LN-24*/ 
/*LN-25*/     constructor(address _token0, address _token1) {
/*LN-26*/         token0 = _token0;
/*LN-27*/         token1 = _token1;
/*LN-28*/     }
/*LN-29*/ 
/*LN-30*/     /**
/*LN-31*/      * @notice Add liquidity to the pair
/*LN-32*/      */
/*LN-33*/     function mint(address to) external returns (uint256 liquidity) {
/*LN-34*/         uint256 balance0 = IERC20(token0).balanceOf(address(this));
/*LN-35*/         uint256 balance1 = IERC20(token1).balanceOf(address(this));
/*LN-36*/ 
/*LN-37*/         uint256 amount0 = balance0 - reserve0;
/*LN-38*/         uint256 amount1 = balance1 - reserve1;
/*LN-39*/ 
/*LN-40*/         // Simplified liquidity calculation
/*LN-41*/         liquidity = sqrt(amount0 * amount1);
/*LN-42*/ 
/*LN-43*/         reserve0 = uint112(balance0);
/*LN-44*/         reserve1 = uint112(balance1);
/*LN-45*/ 
/*LN-46*/         return liquidity;
/*LN-47*/     }
/*LN-48*/ 
/*LN-49*/     function swap(
/*LN-50*/         uint256 amount0Out,
/*LN-51*/         uint256 amount1Out,
/*LN-52*/         address to,
/*LN-53*/         bytes calldata data
/*LN-54*/     ) external {
/*LN-55*/         require(
/*LN-56*/             amount0Out > 0 || amount1Out > 0,
/*LN-57*/             "UraniumSwap: INSUFFICIENT_OUTPUT_AMOUNT"
/*LN-58*/         );
/*LN-59*/ 
/*LN-60*/         uint112 _reserve0 = reserve0;
/*LN-61*/         uint112 _reserve1 = reserve1;
/*LN-62*/ 
/*LN-63*/         require(
/*LN-64*/             amount0Out < _reserve0 && amount1Out < _reserve1,
/*LN-65*/             "UraniumSwap: INSUFFICIENT_LIQUIDITY"
/*LN-66*/         );
/*LN-67*/ 
/*LN-68*/         // Transfer tokens out
/*LN-69*/         if (amount0Out > 0) IERC20(token0).transfer(to, amount0Out);
/*LN-70*/         if (amount1Out > 0) IERC20(token1).transfer(to, amount1Out);
/*LN-71*/ 
/*LN-72*/         // Get balances after transfer
/*LN-73*/         uint256 balance0 = IERC20(token0).balanceOf(address(this));
/*LN-74*/         uint256 balance1 = IERC20(token1).balanceOf(address(this));
/*LN-75*/ 
/*LN-76*/         // Calculate input amounts
/*LN-77*/         uint256 amount0In = balance0 > _reserve0 - amount0Out
/*LN-78*/             ? balance0 - (_reserve0 - amount0Out)
/*LN-79*/             : 0;
/*LN-80*/         uint256 amount1In = balance1 > _reserve1 - amount1Out
/*LN-81*/             ? balance1 - (_reserve1 - amount1Out)
/*LN-82*/             : 0;
/*LN-83*/ 
/*LN-84*/         require(
/*LN-85*/             amount0In > 0 || amount1In > 0,
/*LN-86*/             "UraniumSwap: INSUFFICIENT_INPUT_AMOUNT"
/*LN-87*/         );
/*LN-88*/ 
/*LN-89*/         // Fee calculation uses 10000 scale (0.16% = 16/10000)
/*LN-90*/         uint256 balance0Adjusted = balance0 * 10000 - amount0In * TOTAL_FEE;
/*LN-91*/         uint256 balance1Adjusted = balance1 * 10000 - amount1In * TOTAL_FEE;
/*LN-92*/ 
/*LN-93*/         // K check uses 1000 scale (should be 10000 to match above!)
/*LN-94*/ 
/*LN-95*/         require(
/*LN-96*/             balance0Adjusted * balance1Adjusted >=
/*LN-97*/                 uint256(_reserve0) * _reserve1 * (1000 ** 2),
/*LN-98*/             "UraniumSwap: K"
/*LN-99*/         );
/*LN-100*/ 
/*LN-101*/         // Update reserves
/*LN-102*/         reserve0 = uint112(balance0);
/*LN-103*/         reserve1 = uint112(balance1);
/*LN-104*/     }
/*LN-105*/ 
/*LN-106*/     /**
/*LN-107*/      * @notice Get current reserves
/*LN-108*/      */
/*LN-109*/     function getReserves() external view returns (uint112, uint112, uint32) {
/*LN-110*/         return (reserve0, reserve1, 0);
/*LN-111*/     }
/*LN-112*/ 
/*LN-113*/     /**
/*LN-114*/      * @notice Helper function for square root
/*LN-115*/      */
/*LN-116*/     function sqrt(uint256 y) internal pure returns (uint256 z) {
/*LN-117*/         if (y > 3) {
/*LN-118*/             z = y;
/*LN-119*/             uint256 x = y / 2 + 1;
/*LN-120*/             while (x < z) {
/*LN-121*/                 z = x;
/*LN-122*/                 x = (y / x + x) / 2;
/*LN-123*/             }
/*LN-124*/         } else if (y != 0) {
/*LN-125*/             z = 1;
/*LN-126*/         }
/*LN-127*/     }
/*LN-128*/ }
/*LN-129*/ 
/*LN-130*/ 
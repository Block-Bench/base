/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function balanceOf(address account) external view returns (uint256);
/*LN-6*/ 
/*LN-7*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-8*/ }
/*LN-9*/ 
/*LN-10*/ contract IndexPool {
/*LN-11*/     struct Token {
/*LN-12*/         address addr;
/*LN-13*/         uint256 balance;
/*LN-14*/         uint256 weight; // stored as percentage (100 = 100%)
/*LN-15*/     }
/*LN-16*/ 
/*LN-17*/     mapping(address => Token) public tokens;
/*LN-18*/     address[] public tokenList;
/*LN-19*/     uint256 public totalWeight;
/*LN-20*/ 
/*LN-21*/     constructor() {
/*LN-22*/         totalWeight = 100;
/*LN-23*/     }
/*LN-24*/ 
/*LN-25*/     function addToken(address token, uint256 initialWeight) external {
/*LN-26*/         tokens[token] = Token({addr: token, balance: 0, weight: initialWeight});
/*LN-27*/         tokenList.push(token);
/*LN-28*/     }
/*LN-29*/ 
/*LN-30*/     function swap(
/*LN-31*/         address tokenIn,
/*LN-32*/         address tokenOut,
/*LN-33*/         uint256 amountIn
/*LN-34*/     ) external returns (uint256 amountOut) {
/*LN-35*/         require(tokens[tokenIn].addr != address(0), "Invalid token");
/*LN-36*/         require(tokens[tokenOut].addr != address(0), "Invalid token");
/*LN-37*/ 
/*LN-38*/         // Transfer tokens in
/*LN-39*/         IERC20(tokenIn).transfer(address(this), amountIn);
/*LN-40*/         tokens[tokenIn].balance += amountIn;
/*LN-41*/ 
/*LN-42*/         // Calculate amount out based on current weights
/*LN-43*/         amountOut = calculateSwapAmount(tokenIn, tokenOut, amountIn);
/*LN-44*/ 
/*LN-45*/         // Transfer tokens out
/*LN-46*/         require(
/*LN-47*/             tokens[tokenOut].balance >= amountOut,
/*LN-48*/             "Insufficient liquidity"
/*LN-49*/         );
/*LN-50*/         tokens[tokenOut].balance -= amountOut;
/*LN-51*/         IERC20(tokenOut).transfer(msg.sender, amountOut);
/*LN-52*/ 
/*LN-53*/         _updateWeights();
/*LN-54*/ 
/*LN-55*/         return amountOut;
/*LN-56*/     }
/*LN-57*/ 
/*LN-58*/     /**
/*LN-59*/      * @notice Calculate swap amount based on token weights
/*LN-60*/      */
/*LN-61*/     function calculateSwapAmount(
/*LN-62*/         address tokenIn,
/*LN-63*/         address tokenOut,
/*LN-64*/         uint256 amountIn
/*LN-65*/     ) public view returns (uint256) {
/*LN-66*/         uint256 weightIn = tokens[tokenIn].weight;
/*LN-67*/         uint256 weightOut = tokens[tokenOut].weight;
/*LN-68*/         uint256 balanceOut = tokens[tokenOut].balance;
/*LN-69*/ 
/*LN-70*/         // Simplified constant product with weights: x * y = k * (w1/w2)
/*LN-71*/         // amountOut = balanceOut * amountIn * weightOut / (balanceIn * weightIn + amountIn * weightOut)
/*LN-72*/ 
/*LN-73*/         uint256 numerator = balanceOut * amountIn * weightOut;
/*LN-74*/         uint256 denominator = tokens[tokenIn].balance *
/*LN-75*/             weightIn +
/*LN-76*/             amountIn *
/*LN-77*/             weightOut;
/*LN-78*/ 
/*LN-79*/         return numerator / denominator;
/*LN-80*/     }
/*LN-81*/ 
/*LN-82*/     function _updateWeights() internal {
/*LN-83*/         uint256 totalValue = 0;
/*LN-84*/ 
/*LN-85*/         // Calculate total value in pool
/*LN-86*/         for (uint256 i = 0; i < tokenList.length; i++) {
/*LN-87*/             address token = tokenList[i];
/*LN-88*/ 
/*LN-89*/             // For this simplified version, we use balance as proxy for value
/*LN-90*/             totalValue += tokens[token].balance;
/*LN-91*/         }
/*LN-92*/ 
/*LN-93*/         // Update each token's weight proportional to its balance
/*LN-94*/         for (uint256 i = 0; i < tokenList.length; i++) {
/*LN-95*/             address token = tokenList[i];
/*LN-96*/ 
/*LN-97*/             // draining liquidity of one token
/*LN-98*/             tokens[token].weight = (tokens[token].balance * 100) / totalValue;
/*LN-99*/         }
/*LN-100*/     }
/*LN-101*/ 
/*LN-102*/     /**
/*LN-103*/      * @notice Get current token weight
/*LN-104*/      */
/*LN-105*/     function getWeight(address token) external view returns (uint256) {
/*LN-106*/         return tokens[token].weight;
/*LN-107*/     }
/*LN-108*/ 
/*LN-109*/     /**
/*LN-110*/      * @notice Add liquidity to pool
/*LN-111*/      */
/*LN-112*/     function addLiquidity(address token, uint256 amount) external {
/*LN-113*/         require(tokens[token].addr != address(0), "Invalid token");
/*LN-114*/         IERC20(token).transfer(address(this), amount);
/*LN-115*/         tokens[token].balance += amount;
/*LN-116*/         _updateWeights();
/*LN-117*/     }
/*LN-118*/ }
/*LN-119*/ 
/*LN-120*/ 
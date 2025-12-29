/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function balanceOf(address account) external view returns (uint256);
/*LN-5*/ 
/*LN-6*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-7*/ }
/*LN-8*/ 
/*LN-9*/ contract IndexPool {
/*LN-10*/     struct Token {
/*LN-11*/         address addr;
/*LN-12*/         uint256 balance;
/*LN-13*/         uint256 weight;
/*LN-14*/     }
/*LN-15*/ 
/*LN-16*/     mapping(address => Token) public tokens;
/*LN-17*/     address[] public tokenList;
/*LN-18*/     uint256 public totalWeight;
/*LN-19*/ 
/*LN-20*/     constructor() {
/*LN-21*/         totalWeight = 100;
/*LN-22*/     }
/*LN-23*/ 
/*LN-24*/     function addToken(address token, uint256 initialWeight) external {
/*LN-25*/         tokens[token] = Token({addr: token, balance: 0, weight: initialWeight});
/*LN-26*/         tokenList.push(token);
/*LN-27*/     }
/*LN-28*/ 
/*LN-29*/     function swap(
/*LN-30*/         address tokenIn,
/*LN-31*/         address tokenOut,
/*LN-32*/         uint256 amountIn
/*LN-33*/     ) external returns (uint256 amountOut) {
/*LN-34*/         require(tokens[tokenIn].addr != address(0), "Invalid token");
/*LN-35*/         require(tokens[tokenOut].addr != address(0), "Invalid token");
/*LN-36*/ 
/*LN-37*/ 
/*LN-38*/         IERC20(tokenIn).transfer(address(this), amountIn);
/*LN-39*/         tokens[tokenIn].balance += amountIn;
/*LN-40*/ 
/*LN-41*/ 
/*LN-42*/         amountOut = calculateSwapAmount(tokenIn, tokenOut, amountIn);
/*LN-43*/ 
/*LN-44*/ 
/*LN-45*/         require(
/*LN-46*/             tokens[tokenOut].balance >= amountOut,
/*LN-47*/             "Insufficient liquidity"
/*LN-48*/         );
/*LN-49*/         tokens[tokenOut].balance -= amountOut;
/*LN-50*/         IERC20(tokenOut).transfer(msg.sender, amountOut);
/*LN-51*/ 
/*LN-52*/         _updateWeights();
/*LN-53*/ 
/*LN-54*/         return amountOut;
/*LN-55*/     }
/*LN-56*/ 
/*LN-57*/ 
/*LN-58*/     function calculateSwapAmount(
/*LN-59*/         address tokenIn,
/*LN-60*/         address tokenOut,
/*LN-61*/         uint256 amountIn
/*LN-62*/     ) public view returns (uint256) {
/*LN-63*/         uint256 weightIn = tokens[tokenIn].weight;
/*LN-64*/         uint256 weightOut = tokens[tokenOut].weight;
/*LN-65*/         uint256 balanceOut = tokens[tokenOut].balance;
/*LN-66*/ 
/*LN-67*/ 
/*LN-68*/         uint256 numerator = balanceOut * amountIn * weightOut;
/*LN-69*/         uint256 denominator = tokens[tokenIn].balance *
/*LN-70*/             weightIn +
/*LN-71*/             amountIn *
/*LN-72*/             weightOut;
/*LN-73*/ 
/*LN-74*/         return numerator / denominator;
/*LN-75*/     }
/*LN-76*/ 
/*LN-77*/     function _updateWeights() internal {
/*LN-78*/         uint256 totalValue = 0;
/*LN-79*/ 
/*LN-80*/ 
/*LN-81*/         for (uint256 i = 0; i < tokenList.length; i++) {
/*LN-82*/             address token = tokenList[i];
/*LN-83*/ 
/*LN-84*/ 
/*LN-85*/             totalValue += tokens[token].balance;
/*LN-86*/         }
/*LN-87*/ 
/*LN-88*/ 
/*LN-89*/         for (uint256 i = 0; i < tokenList.length; i++) {
/*LN-90*/             address token = tokenList[i];
/*LN-91*/ 
/*LN-92*/ 
/*LN-93*/             tokens[token].weight = (tokens[token].balance * 100) / totalValue;
/*LN-94*/         }
/*LN-95*/     }
/*LN-96*/ 
/*LN-97*/ 
/*LN-98*/     function getWeight(address token) external view returns (uint256) {
/*LN-99*/         return tokens[token].weight;
/*LN-100*/     }
/*LN-101*/ 
/*LN-102*/ 
/*LN-103*/     function addLiquidity(address token, uint256 amount) external {
/*LN-104*/         require(tokens[token].addr != address(0), "Invalid token");
/*LN-105*/         IERC20(token).transfer(address(this), amount);
/*LN-106*/         tokens[token].balance += amount;
/*LN-107*/         _updateWeights();
/*LN-108*/     }
/*LN-109*/ }
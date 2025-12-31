/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IUniswapV2Pair {
/*LN-5*/     function getReserves()
/*LN-6*/         external
/*LN-7*/         view
/*LN-8*/         returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
/*LN-9*/ 
/*LN-10*/     function totalSupply() external view returns (uint256);
/*LN-11*/ }
/*LN-12*/ 
/*LN-13*/ interface IERC20 {
/*LN-14*/     function balanceOf(address account) external view returns (uint256);
/*LN-15*/ 
/*LN-16*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-17*/ 
/*LN-18*/     function transferFrom(
/*LN-19*/         address from,
/*LN-20*/         address to,
/*LN-21*/         uint256 amount
/*LN-22*/     ) external returns (bool);
/*LN-23*/ }
/*LN-24*/ 
/*LN-25*/ contract CollateralVault {
/*LN-26*/     struct Position {
/*LN-27*/         uint256 lpTokenAmount;
/*LN-28*/         uint256 borrowed;
/*LN-29*/     }
/*LN-30*/ 
/*LN-31*/     mapping(address => Position) public positions;
/*LN-32*/ 
/*LN-33*/     address public lpToken;
/*LN-34*/     address public stablecoin;
/*LN-35*/     uint256 public constant COLLATERAL_RATIO = 150; // 150% collateralization
/*LN-36*/ 
/*LN-37*/     constructor(address _lpToken, address _stablecoin) {
/*LN-38*/         lpToken = _lpToken;
/*LN-39*/         stablecoin = _stablecoin;
/*LN-40*/     }
/*LN-41*/ 
/*LN-42*/     /**
/*LN-43*/      * @notice Deposit LP tokens as collateral
/*LN-44*/      */
/*LN-45*/     function deposit(uint256 amount) external {
/*LN-46*/         IERC20(lpToken).transferFrom(msg.sender, address(this), amount);
/*LN-47*/         positions[msg.sender].lpTokenAmount += amount;
/*LN-48*/     }
/*LN-49*/ 
/*LN-50*/     function borrow(uint256 amount) external {
/*LN-51*/         uint256 collateralValue = getLPTokenValue(
/*LN-52*/             positions[msg.sender].lpTokenAmount
/*LN-53*/         );
/*LN-54*/         uint256 maxBorrow = (collateralValue * 100) / COLLATERAL_RATIO;
/*LN-55*/ 
/*LN-56*/         require(
/*LN-57*/             positions[msg.sender].borrowed + amount <= maxBorrow,
/*LN-58*/             "Insufficient collateral"
/*LN-59*/         );
/*LN-60*/ 
/*LN-61*/         positions[msg.sender].borrowed += amount;
/*LN-62*/         IERC20(stablecoin).transfer(msg.sender, amount);
/*LN-63*/     }
/*LN-64*/ 
/*LN-65*/     function getLPTokenValue(uint256 lpAmount) public view returns (uint256) {
/*LN-66*/         if (lpAmount == 0) return 0;
/*LN-67*/ 
/*LN-68*/         IUniswapV2Pair pair = IUniswapV2Pair(lpToken);
/*LN-69*/ 
/*LN-70*/         (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
/*LN-71*/         uint256 totalSupply = pair.totalSupply();
/*LN-72*/ 
/*LN-73*/         // Calculate share of reserves owned by these LP tokens
/*LN-74*/ 
/*LN-75*/         uint256 amount0 = (uint256(reserve0) * lpAmount) / totalSupply;
/*LN-76*/         uint256 amount1 = (uint256(reserve1) * lpAmount) / totalSupply;
/*LN-77*/ 
/*LN-78*/         // For simplicity, assume token0 is stablecoin ($1) and token1 is ETH
/*LN-79*/         // In reality, would need oracle for ETH price
/*LN-80*/ 
/*LN-81*/         uint256 value0 = amount0; // amount0 is stablecoin, worth face value
/*LN-82*/ 
/*LN-83*/         // This simplified version just adds both reserves
/*LN-84*/ 
/*LN-85*/         uint256 totalValue = amount0 + amount1;
/*LN-86*/ 
/*LN-87*/         return totalValue;
/*LN-88*/     }
/*LN-89*/ 
/*LN-90*/     /**
/*LN-91*/      * @notice Repay borrowed amount
/*LN-92*/      */
/*LN-93*/     function repay(uint256 amount) external {
/*LN-94*/         require(positions[msg.sender].borrowed >= amount, "Repay exceeds debt");
/*LN-95*/ 
/*LN-96*/         IERC20(stablecoin).transferFrom(msg.sender, address(this), amount);
/*LN-97*/         positions[msg.sender].borrowed -= amount;
/*LN-98*/     }
/*LN-99*/ 
/*LN-100*/     /**
/*LN-101*/      * @notice Withdraw LP tokens
/*LN-102*/      */
/*LN-103*/     function withdraw(uint256 amount) external {
/*LN-104*/         require(
/*LN-105*/             positions[msg.sender].lpTokenAmount >= amount,
/*LN-106*/             "Insufficient balance"
/*LN-107*/         );
/*LN-108*/ 
/*LN-109*/         // Check that position remains healthy after withdrawal
/*LN-110*/         uint256 remainingLP = positions[msg.sender].lpTokenAmount - amount;
/*LN-111*/         uint256 remainingValue = getLPTokenValue(remainingLP);
/*LN-112*/         uint256 maxBorrow = (remainingValue * 100) / COLLATERAL_RATIO;
/*LN-113*/ 
/*LN-114*/         require(
/*LN-115*/             positions[msg.sender].borrowed <= maxBorrow,
/*LN-116*/             "Withdrawal would liquidate position"
/*LN-117*/         );
/*LN-118*/ 
/*LN-119*/         positions[msg.sender].lpTokenAmount -= amount;
/*LN-120*/         IERC20(lpToken).transfer(msg.sender, amount);
/*LN-121*/     }
/*LN-122*/ }
/*LN-123*/ 
/*LN-124*/ 
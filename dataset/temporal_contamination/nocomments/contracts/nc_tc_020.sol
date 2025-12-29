/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IUniswapV2Pair {
/*LN-4*/     function getReserves()
/*LN-5*/         external
/*LN-6*/         view
/*LN-7*/         returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
/*LN-8*/ 
/*LN-9*/     function totalSupply() external view returns (uint256);
/*LN-10*/ }
/*LN-11*/ 
/*LN-12*/ interface IERC20 {
/*LN-13*/     function balanceOf(address account) external view returns (uint256);
/*LN-14*/ 
/*LN-15*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-16*/ 
/*LN-17*/     function transferFrom(
/*LN-18*/         address from,
/*LN-19*/         address to,
/*LN-20*/         uint256 amount
/*LN-21*/     ) external returns (bool);
/*LN-22*/ }
/*LN-23*/ 
/*LN-24*/ contract CollateralVault {
/*LN-25*/     struct Position {
/*LN-26*/         uint256 lpTokenAmount;
/*LN-27*/         uint256 borrowed;
/*LN-28*/     }
/*LN-29*/ 
/*LN-30*/     mapping(address => Position) public positions;
/*LN-31*/ 
/*LN-32*/     address public lpToken;
/*LN-33*/     address public stablecoin;
/*LN-34*/     uint256 public constant COLLATERAL_RATIO = 150;
/*LN-35*/ 
/*LN-36*/     constructor(address _lpToken, address _stablecoin) {
/*LN-37*/         lpToken = _lpToken;
/*LN-38*/         stablecoin = _stablecoin;
/*LN-39*/     }
/*LN-40*/ 
/*LN-41*/ 
/*LN-42*/     function deposit(uint256 amount) external {
/*LN-43*/         IERC20(lpToken).transferFrom(msg.sender, address(this), amount);
/*LN-44*/         positions[msg.sender].lpTokenAmount += amount;
/*LN-45*/     }
/*LN-46*/ 
/*LN-47*/     function borrow(uint256 amount) external {
/*LN-48*/         uint256 collateralValue = getLPTokenValue(
/*LN-49*/             positions[msg.sender].lpTokenAmount
/*LN-50*/         );
/*LN-51*/         uint256 maxBorrow = (collateralValue * 100) / COLLATERAL_RATIO;
/*LN-52*/ 
/*LN-53*/         require(
/*LN-54*/             positions[msg.sender].borrowed + amount <= maxBorrow,
/*LN-55*/             "Insufficient collateral"
/*LN-56*/         );
/*LN-57*/ 
/*LN-58*/         positions[msg.sender].borrowed += amount;
/*LN-59*/         IERC20(stablecoin).transfer(msg.sender, amount);
/*LN-60*/     }
/*LN-61*/ 
/*LN-62*/     function getLPTokenValue(uint256 lpAmount) public view returns (uint256) {
/*LN-63*/         if (lpAmount == 0) return 0;
/*LN-64*/ 
/*LN-65*/         IUniswapV2Pair pair = IUniswapV2Pair(lpToken);
/*LN-66*/ 
/*LN-67*/         (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
/*LN-68*/         uint256 totalSupply = pair.totalSupply();
/*LN-69*/ 
/*LN-70*/ 
/*LN-71*/         uint256 amount0 = (uint256(reserve0) * lpAmount) / totalSupply;
/*LN-72*/         uint256 amount1 = (uint256(reserve1) * lpAmount) / totalSupply;
/*LN-73*/ 
/*LN-74*/ 
/*LN-75*/         uint256 value0 = amount0;
/*LN-76*/ 
/*LN-77*/ 
/*LN-78*/         uint256 totalValue = amount0 + amount1;
/*LN-79*/ 
/*LN-80*/         return totalValue;
/*LN-81*/     }
/*LN-82*/ 
/*LN-83*/ 
/*LN-84*/     function repay(uint256 amount) external {
/*LN-85*/         require(positions[msg.sender].borrowed >= amount, "Repay exceeds debt");
/*LN-86*/ 
/*LN-87*/         IERC20(stablecoin).transferFrom(msg.sender, address(this), amount);
/*LN-88*/         positions[msg.sender].borrowed -= amount;
/*LN-89*/     }
/*LN-90*/ 
/*LN-91*/ 
/*LN-92*/     function withdraw(uint256 amount) external {
/*LN-93*/         require(
/*LN-94*/             positions[msg.sender].lpTokenAmount >= amount,
/*LN-95*/             "Insufficient balance"
/*LN-96*/         );
/*LN-97*/ 
/*LN-98*/ 
/*LN-99*/         uint256 remainingLP = positions[msg.sender].lpTokenAmount - amount;
/*LN-100*/         uint256 remainingValue = getLPTokenValue(remainingLP);
/*LN-101*/         uint256 maxBorrow = (remainingValue * 100) / COLLATERAL_RATIO;
/*LN-102*/ 
/*LN-103*/         require(
/*LN-104*/             positions[msg.sender].borrowed <= maxBorrow,
/*LN-105*/             "Withdrawal would liquidate position"
/*LN-106*/         );
/*LN-107*/ 
/*LN-108*/         positions[msg.sender].lpTokenAmount -= amount;
/*LN-109*/         IERC20(lpToken).transfer(msg.sender, amount);
/*LN-110*/     }
/*LN-111*/ }
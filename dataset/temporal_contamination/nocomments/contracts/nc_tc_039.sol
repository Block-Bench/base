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
/*LN-17*/ interface IWETH {
/*LN-18*/     function deposit() external payable;
/*LN-19*/ 
/*LN-20*/     function withdraw(uint256 amount) external;
/*LN-21*/ 
/*LN-22*/     function balanceOf(address account) external view returns (uint256);
/*LN-23*/ }
/*LN-24*/ 
/*LN-25*/ contract BatchSolver {
/*LN-26*/     IWETH public immutable WETH;
/*LN-27*/     address public immutable settlement;
/*LN-28*/ 
/*LN-29*/     constructor(address _weth, address _settlement) {
/*LN-30*/         WETH = IWETH(_weth);
/*LN-31*/         settlement = _settlement;
/*LN-32*/     }
/*LN-33*/ 
/*LN-34*/     function uniswapV3SwapCallback(
/*LN-35*/         int256 amount0Delta,
/*LN-36*/         int256 amount1Delta,
/*LN-37*/         bytes calldata data
/*LN-38*/     ) external payable {
/*LN-39*/ 
/*LN-40*/ 
/*LN-41*/         (
/*LN-42*/             uint256 price,
/*LN-43*/             address solver,
/*LN-44*/             address tokenIn,
/*LN-45*/             address recipient
/*LN-46*/         ) = abi.decode(data, (uint256, address, address, address));
/*LN-47*/ 
/*LN-48*/ 
/*LN-49*/         uint256 amountToPay;
/*LN-50*/         if (amount0Delta > 0) {
/*LN-51*/             amountToPay = uint256(amount0Delta);
/*LN-52*/         } else {
/*LN-53*/             amountToPay = uint256(amount1Delta);
/*LN-54*/         }
/*LN-55*/ 
/*LN-56*/ 
/*LN-57*/         if (tokenIn == address(WETH)) {
/*LN-58*/             WETH.withdraw(amountToPay);
/*LN-59*/             payable(recipient).transfer(amountToPay);
/*LN-60*/         } else {
/*LN-61*/             IERC20(tokenIn).transfer(recipient, amountToPay);
/*LN-62*/         }
/*LN-63*/     }
/*LN-64*/ 
/*LN-65*/ 
/*LN-66*/     function executeSettlement(bytes calldata settlementData) external {
/*LN-67*/         require(msg.sender == settlement, "Only settlement");
/*LN-68*/ 
/*LN-69*/     }
/*LN-70*/ 
/*LN-71*/     receive() external payable {}
/*LN-72*/ }
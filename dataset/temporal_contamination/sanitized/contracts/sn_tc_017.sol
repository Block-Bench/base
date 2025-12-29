/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-6*/ 
/*LN-7*/     function balanceOf(address account) external view returns (uint256);
/*LN-8*/ }
/*LN-9*/ 
/*LN-10*/ interface IJar {
/*LN-11*/     function token() external view returns (address);
/*LN-12*/ 
/*LN-13*/     function withdraw(uint256 amount) external;
/*LN-14*/ }
/*LN-15*/ 
/*LN-16*/ interface IStrategy {
/*LN-17*/     function withdrawAll() external;
/*LN-18*/ 
/*LN-19*/     function withdraw(address token) external;
/*LN-20*/ }
/*LN-21*/ 
/*LN-22*/ contract BasicController {
/*LN-23*/     address public governance;
/*LN-24*/     mapping(address => address) public strategies; // jar => strategy
/*LN-25*/ 
/*LN-26*/     constructor() {
/*LN-27*/         governance = msg.sender;
/*LN-28*/     }
/*LN-29*/ 
/*LN-30*/     function swapExactJarForJar(
/*LN-31*/         address _fromJar,
/*LN-32*/         address _toJar,
/*LN-33*/         uint256 _fromJarAmount,
/*LN-34*/         uint256 _toJarMinAmount,
/*LN-35*/         address[] calldata _targets,
/*LN-36*/         bytes[] calldata _data
/*LN-37*/     ) external {
/*LN-38*/         require(_targets.length == _data.length, "Length mismatch");
/*LN-39*/ 
/*LN-40*/         for (uint256 i = 0; i < _targets.length; i++) {
/*LN-41*/             (bool success, ) = _targets[i].call(_data[i]);
/*LN-42*/             require(success, "Call failed");
/*LN-43*/         }
/*LN-44*/ 
/*LN-45*/         // The rest of swap logic would go here
/*LN-46*/ 
/*LN-47*/     }
/*LN-48*/ 
/*LN-49*/     /**
/*LN-50*/      * @notice Set strategy for a jar
/*LN-51*/      * @dev Only governance should call this
/*LN-52*/      */
/*LN-53*/     function setStrategy(address jar, address strategy) external {
/*LN-54*/         require(msg.sender == governance, "Not governance");
/*LN-55*/         strategies[jar] = strategy;
/*LN-56*/     }
/*LN-57*/ }
/*LN-58*/ 
/*LN-59*/ contract YieldStrategy {
/*LN-60*/     address public controller;
/*LN-61*/     address public want; // The token this strategy manages
/*LN-62*/ 
/*LN-63*/     constructor(address _controller, address _want) {
/*LN-64*/         controller = _controller;
/*LN-65*/         want = _want;
/*LN-66*/     }
/*LN-67*/ 
/*LN-68*/     /**
/*LN-69*/      * @notice Withdraw all funds from strategy
/*LN-70*/      * @dev Should only be callable by controller, but no check!
/*LN-71*/      */
/*LN-72*/     function withdrawAll() external {
/*LN-73*/ 
/*LN-74*/         // Should check: require(msg.sender == controller, "Not controller");
/*LN-75*/ 
/*LN-76*/         uint256 balance = IERC20(want).balanceOf(address(this));
/*LN-77*/         IERC20(want).transfer(controller, balance);
/*LN-78*/     }
/*LN-79*/ 
/*LN-80*/     /**
/*LN-81*/      * @notice Withdraw specific token
/*LN-82*/      * @dev Also lacks access control
/*LN-83*/      */
/*LN-84*/     function withdraw(address token) external {
/*LN-85*/ 
/*LN-86*/         uint256 balance = IERC20(token).balanceOf(address(this));
/*LN-87*/         IERC20(token).transfer(controller, balance);
/*LN-88*/     }
/*LN-89*/ }
/*LN-90*/ 
/*LN-91*/ 
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
/*LN-16*/ interface IStablePool {
/*LN-17*/     function get_virtual_price() external view returns (uint256);
/*LN-18*/ 
/*LN-19*/     function add_liquidity(
/*LN-20*/         uint256[3] calldata amounts,
/*LN-21*/         uint256 minMintAmount
/*LN-22*/     ) external;
/*LN-23*/ }
/*LN-24*/ 
/*LN-25*/ contract SimplifiedOracle {
/*LN-26*/     IStablePool public stablePool;
/*LN-27*/ 
/*LN-28*/     constructor(address _stablePool) {
/*LN-29*/         stablePool = IStablePool(_stablePool);
/*LN-30*/     }
/*LN-31*/ 
/*LN-32*/     function getPrice() external view returns (uint256) {
/*LN-33*/         return stablePool.get_virtual_price();
/*LN-34*/     }
/*LN-35*/ }
/*LN-36*/ 
/*LN-37*/ contract SyntheticLending {
/*LN-38*/     struct Position {
/*LN-39*/         uint256 collateral;
/*LN-40*/         uint256 borrowed;
/*LN-41*/     }
/*LN-42*/ 
/*LN-43*/     mapping(address => Position) public positions;
/*LN-44*/ 
/*LN-45*/     address public collateralToken;
/*LN-46*/     address public borrowToken;
/*LN-47*/     address public oracle;
/*LN-48*/ 
/*LN-49*/     uint256 public constant COLLATERAL_FACTOR = 80;
/*LN-50*/ 
/*LN-51*/     constructor(
/*LN-52*/         address _collateralToken,
/*LN-53*/         address _borrowToken,
/*LN-54*/         address _oracle
/*LN-55*/     ) {
/*LN-56*/         collateralToken = _collateralToken;
/*LN-57*/         borrowToken = _borrowToken;
/*LN-58*/         oracle = _oracle;
/*LN-59*/     }
/*LN-60*/ 
/*LN-61*/     /**
/*LN-62*/      * @notice Deposit collateral
/*LN-63*/      */
/*LN-64*/     function deposit(uint256 amount) external {
/*LN-65*/         IERC20(collateralToken).transferFrom(msg.sender, address(this), amount);
/*LN-66*/         positions[msg.sender].collateral += amount;
/*LN-67*/     }
/*LN-68*/ 
/*LN-69*/     function borrow(uint256 amount) external {
/*LN-70*/         uint256 collateralValue = getCollateralValue(msg.sender);
/*LN-71*/         uint256 maxBorrow = (collateralValue * COLLATERAL_FACTOR) / 100;
/*LN-72*/ 
/*LN-73*/         require(
/*LN-74*/             positions[msg.sender].borrowed + amount <= maxBorrow,
/*LN-75*/             "Insufficient collateral"
/*LN-76*/         );
/*LN-77*/ 
/*LN-78*/         positions[msg.sender].borrowed += amount;
/*LN-79*/         IERC20(borrowToken).transfer(msg.sender, amount);
/*LN-80*/     }
/*LN-81*/ 
/*LN-82*/     function getCollateralValue(address user) public view returns (uint256) {
/*LN-83*/         uint256 collateralAmount = positions[user].collateral;
/*LN-84*/         uint256 price = SimplifiedOracle(oracle).getPrice();
/*LN-85*/ 
/*LN-86*/         return (collateralAmount * price) / 1e18;
/*LN-87*/     }
/*LN-88*/ }
/*LN-89*/ 
/*LN-90*/ 
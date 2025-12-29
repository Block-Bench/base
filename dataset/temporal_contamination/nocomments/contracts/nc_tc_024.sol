/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function balanceOf(address account) external view returns (uint256);
/*LN-5*/ 
/*LN-6*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-7*/ 
/*LN-8*/     function transferFrom(
/*LN-9*/         address from,
/*LN-10*/         address to,
/*LN-11*/         uint256 amount
/*LN-12*/     ) external returns (bool);
/*LN-13*/ }
/*LN-14*/ 
/*LN-15*/ interface IStablePool {
/*LN-16*/     function get_virtual_price() external view returns (uint256);
/*LN-17*/ 
/*LN-18*/     function add_liquidity(
/*LN-19*/         uint256[3] calldata amounts,
/*LN-20*/         uint256 minMintAmount
/*LN-21*/     ) external;
/*LN-22*/ }
/*LN-23*/ 
/*LN-24*/ contract SimplifiedOracle {
/*LN-25*/     IStablePool public stablePool;
/*LN-26*/ 
/*LN-27*/     constructor(address _stablePool) {
/*LN-28*/         stablePool = IStablePool(_stablePool);
/*LN-29*/     }
/*LN-30*/ 
/*LN-31*/     function getPrice() external view returns (uint256) {
/*LN-32*/         return stablePool.get_virtual_price();
/*LN-33*/     }
/*LN-34*/ }
/*LN-35*/ 
/*LN-36*/ contract SyntheticLending {
/*LN-37*/     struct Position {
/*LN-38*/         uint256 collateral;
/*LN-39*/         uint256 borrowed;
/*LN-40*/     }
/*LN-41*/ 
/*LN-42*/     mapping(address => Position) public positions;
/*LN-43*/ 
/*LN-44*/     address public collateralToken;
/*LN-45*/     address public borrowToken;
/*LN-46*/     address public oracle;
/*LN-47*/ 
/*LN-48*/     uint256 public constant COLLATERAL_FACTOR = 80;
/*LN-49*/ 
/*LN-50*/     constructor(
/*LN-51*/         address _collateralToken,
/*LN-52*/         address _borrowToken,
/*LN-53*/         address _oracle
/*LN-54*/     ) {
/*LN-55*/         collateralToken = _collateralToken;
/*LN-56*/         borrowToken = _borrowToken;
/*LN-57*/         oracle = _oracle;
/*LN-58*/     }
/*LN-59*/ 
/*LN-60*/ 
/*LN-61*/     function deposit(uint256 amount) external {
/*LN-62*/         IERC20(collateralToken).transferFrom(msg.sender, address(this), amount);
/*LN-63*/         positions[msg.sender].collateral += amount;
/*LN-64*/     }
/*LN-65*/ 
/*LN-66*/     function borrow(uint256 amount) external {
/*LN-67*/         uint256 collateralValue = getCollateralValue(msg.sender);
/*LN-68*/         uint256 maxBorrow = (collateralValue * COLLATERAL_FACTOR) / 100;
/*LN-69*/ 
/*LN-70*/         require(
/*LN-71*/             positions[msg.sender].borrowed + amount <= maxBorrow,
/*LN-72*/             "Insufficient collateral"
/*LN-73*/         );
/*LN-74*/ 
/*LN-75*/         positions[msg.sender].borrowed += amount;
/*LN-76*/         IERC20(borrowToken).transfer(msg.sender, amount);
/*LN-77*/     }
/*LN-78*/ 
/*LN-79*/     function getCollateralValue(address user) public view returns (uint256) {
/*LN-80*/         uint256 collateralAmount = positions[user].collateral;
/*LN-81*/         uint256 price = SimplifiedOracle(oracle).getPrice();
/*LN-82*/ 
/*LN-83*/         return (collateralAmount * price) / 1e18;
/*LN-84*/     }
/*LN-85*/ }
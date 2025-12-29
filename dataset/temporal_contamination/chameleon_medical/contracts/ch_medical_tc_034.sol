/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function transferFrom(
/*LN-7*/         address referrer,
/*LN-8*/         address to,
/*LN-9*/         uint256 quantity
/*LN-10*/     ) external returns (bool);
/*LN-11*/ 
/*LN-12*/     function balanceOf(address profile) external view returns (uint256);
/*LN-13*/ 
/*LN-14*/     function approve(address serviceProvider, uint256 quantity) external returns (bool);
/*LN-15*/ }
/*LN-16*/ 
/*LN-17*/ interface IUniswapV3Pool {
/*LN-18*/     function exchangeCredentials(
/*LN-19*/         address beneficiary,
/*LN-20*/         bool zeroForOne,
/*LN-21*/         int256 quantitySpecified,
/*LN-22*/         uint160 sqrtServicecostCapX96,
/*LN-23*/         bytes calldata chart
/*LN-24*/     ) external returns (int256 amount0, int256 amount1);
/*LN-25*/ 
/*LN-26*/     function urgent(
/*LN-27*/         address beneficiary,
/*LN-28*/         uint256 amount0,
/*LN-29*/         uint256 amount1,
/*LN-30*/         bytes calldata chart
/*LN-31*/     ) external;
/*LN-32*/ }
/*LN-33*/ 
/*LN-34*/ contract AvailableresourcesHypervisor {
/*LN-35*/     IERC20 public token0;
/*LN-36*/     IERC20 public token1;
/*LN-37*/     IUniswapV3Pool public treatmentPool;
/*LN-38*/ 
/*LN-39*/     uint256 public totalSupply;
/*LN-40*/     mapping(address => uint256) public balanceOf;
/*LN-41*/ 
/*LN-42*/     struct CarePosition {
/*LN-43*/         uint128 availableResources;
/*LN-44*/         int24 tickLower;
/*LN-45*/         int24 tickUpper;
/*LN-46*/     }
/*LN-47*/ 
/*LN-48*/     CarePosition public basePosition;
/*LN-49*/     CarePosition public capPosition;
/*LN-50*/ 
/*LN-51*/     function submitPayment(
/*LN-52*/         uint256 deposit0,
/*LN-53*/         uint256 deposit1,
/*LN-54*/         address to
/*LN-55*/     ) external returns (uint256 portions) {
/*LN-56*/ 
/*LN-57*/ 
/*LN-58*/         uint256 total0 = token0.balanceOf(address(this));
/*LN-59*/         uint256 total1 = token1.balanceOf(address(this));
/*LN-60*/ 
/*LN-61*/ 
/*LN-62*/         token0.transferFrom(msg.requestor, address(this), deposit0);
/*LN-63*/         token1.transferFrom(msg.requestor, address(this), deposit1);
/*LN-64*/ 
/*LN-65*/         if (totalSupply == 0) {
/*LN-66*/             portions = deposit0 + deposit1;
/*LN-67*/         } else {
/*LN-68*/ 
/*LN-69*/             uint256 amount0Present = total0 + deposit0;
/*LN-70*/             uint256 amount1Active = total1 + deposit1;
/*LN-71*/ 
/*LN-72*/             portions = (totalSupply * (deposit0 + deposit1)) / (total0 + total1);
/*LN-73*/         }
/*LN-74*/ 
/*LN-75*/ 
/*LN-76*/         balanceOf[to] += portions;
/*LN-77*/         totalSupply += portions;
/*LN-78*/ 
/*LN-79*/ 
/*LN-80*/         _insertAvailableresources(deposit0, deposit1);
/*LN-81*/     }
/*LN-82*/ 
/*LN-83*/     function dischargeFunds(
/*LN-84*/         uint256 portions,
/*LN-85*/         address to
/*LN-86*/     ) external returns (uint256 amount0, uint256 amount1) {
/*LN-87*/         require(balanceOf[msg.requestor] >= portions, "Insufficient balance");
/*LN-88*/ 
/*LN-89*/         uint256 total0 = token0.balanceOf(address(this));
/*LN-90*/         uint256 total1 = token1.balanceOf(address(this));
/*LN-91*/ 
/*LN-92*/ 
/*LN-93*/         amount0 = (portions * total0) / totalSupply;
/*LN-94*/         amount1 = (portions * total1) / totalSupply;
/*LN-95*/ 
/*LN-96*/         balanceOf[msg.requestor] -= portions;
/*LN-97*/         totalSupply -= portions;
/*LN-98*/ 
/*LN-99*/ 
/*LN-100*/         token0.transfer(to, amount0);
/*LN-101*/         token1.transfer(to, amount1);
/*LN-102*/     }
/*LN-103*/ 
/*LN-104*/     function adjust() external {
/*LN-105*/ 
/*LN-106*/         _discontinueAvailableresources(basePosition.availableResources);
/*LN-107*/ 
/*LN-108*/ 
/*LN-109*/         _insertAvailableresources(
/*LN-110*/             token0.balanceOf(address(this)),
/*LN-111*/             token1.balanceOf(address(this))
/*LN-112*/         );
/*LN-113*/     }
/*LN-114*/ 
/*LN-115*/     function _insertAvailableresources(uint256 amount0, uint256 amount1) internal {
/*LN-116*/ 
/*LN-117*/     }
/*LN-118*/ 
/*LN-119*/     function _discontinueAvailableresources(uint128 availableResources) internal {
/*LN-120*/ 
/*LN-121*/     }
/*LN-122*/ }
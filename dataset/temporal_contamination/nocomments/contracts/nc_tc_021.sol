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
/*LN-15*/ contract LiquidityPool {
/*LN-16*/     address public maintainer;
/*LN-17*/     address public baseToken;
/*LN-18*/     address public quoteToken;
/*LN-19*/ 
/*LN-20*/     uint256 public lpFeeRate;
/*LN-21*/     uint256 public baseBalance;
/*LN-22*/     uint256 public quoteBalance;
/*LN-23*/ 
/*LN-24*/     bool public isInitialized;
/*LN-25*/ 
/*LN-26*/     event Initialized(address maintainer, address base, address quote);
/*LN-27*/ 
/*LN-28*/     function init(
/*LN-29*/         address _maintainer,
/*LN-30*/         address _baseToken,
/*LN-31*/         address _quoteToken,
/*LN-32*/         uint256 _lpFeeRate
/*LN-33*/     ) external {
/*LN-34*/ 
/*LN-35*/ 
/*LN-36*/         maintainer = _maintainer;
/*LN-37*/         baseToken = _baseToken;
/*LN-38*/         quoteToken = _quoteToken;
/*LN-39*/         lpFeeRate = _lpFeeRate;
/*LN-40*/ 
/*LN-41*/ 
/*LN-42*/         isInitialized = true;
/*LN-43*/ 
/*LN-44*/         emit Initialized(_maintainer, _baseToken, _quoteToken);
/*LN-45*/     }
/*LN-46*/ 
/*LN-47*/ 
/*LN-48*/     function addLiquidity(uint256 baseAmount, uint256 quoteAmount) external {
/*LN-49*/         require(isInitialized, "Not initialized");
/*LN-50*/ 
/*LN-51*/         IERC20(baseToken).transferFrom(msg.sender, address(this), baseAmount);
/*LN-52*/         IERC20(quoteToken).transferFrom(msg.sender, address(this), quoteAmount);
/*LN-53*/ 
/*LN-54*/         baseBalance += baseAmount;
/*LN-55*/         quoteBalance += quoteAmount;
/*LN-56*/     }
/*LN-57*/ 
/*LN-58*/ 
/*LN-59*/     function swap(
/*LN-60*/         address fromToken,
/*LN-61*/         address toToken,
/*LN-62*/         uint256 fromAmount
/*LN-63*/     ) external returns (uint256 toAmount) {
/*LN-64*/         require(isInitialized, "Not initialized");
/*LN-65*/         require(
/*LN-66*/             (fromToken == baseToken && toToken == quoteToken) ||
/*LN-67*/                 (fromToken == quoteToken && toToken == baseToken),
/*LN-68*/             "Invalid token pair"
/*LN-69*/         );
/*LN-70*/ 
/*LN-71*/ 
/*LN-72*/         IERC20(fromToken).transferFrom(msg.sender, address(this), fromAmount);
/*LN-73*/ 
/*LN-74*/ 
/*LN-75*/         if (fromToken == baseToken) {
/*LN-76*/             toAmount = (quoteBalance * fromAmount) / (baseBalance + fromAmount);
/*LN-77*/             baseBalance += fromAmount;
/*LN-78*/             quoteBalance -= toAmount;
/*LN-79*/         } else {
/*LN-80*/             toAmount = (baseBalance * fromAmount) / (quoteBalance + fromAmount);
/*LN-81*/             quoteBalance += fromAmount;
/*LN-82*/             baseBalance -= toAmount;
/*LN-83*/         }
/*LN-84*/ 
/*LN-85*/ 
/*LN-86*/         uint256 fee = (toAmount * lpFeeRate) / 10000;
/*LN-87*/         toAmount -= fee;
/*LN-88*/ 
/*LN-89*/ 
/*LN-90*/         IERC20(toToken).transfer(msg.sender, toAmount);
/*LN-91*/ 
/*LN-92*/ 
/*LN-93*/         IERC20(toToken).transfer(maintainer, fee);
/*LN-94*/ 
/*LN-95*/         return toAmount;
/*LN-96*/     }
/*LN-97*/ 
/*LN-98*/ 
/*LN-99*/     function claimFees() external {
/*LN-100*/         require(msg.sender == maintainer, "Only maintainer");
/*LN-101*/ 
/*LN-102*/ 
/*LN-103*/         uint256 baseTokenBalance = IERC20(baseToken).balanceOf(address(this));
/*LN-104*/         uint256 quoteTokenBalance = IERC20(quoteToken).balanceOf(address(this));
/*LN-105*/ 
/*LN-106*/ 
/*LN-107*/         if (baseTokenBalance > baseBalance) {
/*LN-108*/             uint256 excess = baseTokenBalance - baseBalance;
/*LN-109*/             IERC20(baseToken).transfer(maintainer, excess);
/*LN-110*/         }
/*LN-111*/ 
/*LN-112*/         if (quoteTokenBalance > quoteBalance) {
/*LN-113*/             uint256 excess = quoteTokenBalance - quoteBalance;
/*LN-114*/             IERC20(quoteToken).transfer(maintainer, excess);
/*LN-115*/         }
/*LN-116*/     }
/*LN-117*/ }
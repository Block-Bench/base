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
/*LN-16*/ contract LiquidityPool {
/*LN-17*/     address public maintainer;
/*LN-18*/     address public baseToken;
/*LN-19*/     address public quoteToken;
/*LN-20*/ 
/*LN-21*/     uint256 public lpFeeRate;
/*LN-22*/     uint256 public baseBalance;
/*LN-23*/     uint256 public quoteBalance;
/*LN-24*/ 
/*LN-25*/     bool public isInitialized;
/*LN-26*/ 
/*LN-27*/     event Initialized(address maintainer, address base, address quote);
/*LN-28*/ 
/*LN-29*/     function init(
/*LN-30*/         address _maintainer,
/*LN-31*/         address _baseToken,
/*LN-32*/         address _quoteToken,
/*LN-33*/         uint256 _lpFeeRate
/*LN-34*/     ) external {
/*LN-35*/ 
/*LN-36*/         // Should have: require(!isInitialized, "Already initialized");
/*LN-37*/ 
/*LN-38*/         maintainer = _maintainer;
/*LN-39*/         baseToken = _baseToken;
/*LN-40*/         quoteToken = _quoteToken;
/*LN-41*/         lpFeeRate = _lpFeeRate;
/*LN-42*/ 
/*LN-43*/         // Even though we set isInitialized = true, the damage is done
/*LN-44*/ 
/*LN-45*/         isInitialized = true;
/*LN-46*/ 
/*LN-47*/         emit Initialized(_maintainer, _baseToken, _quoteToken);
/*LN-48*/     }
/*LN-49*/ 
/*LN-50*/     /**
/*LN-51*/      * @notice Add liquidity to pool
/*LN-52*/      */
/*LN-53*/     function addLiquidity(uint256 baseAmount, uint256 quoteAmount) external {
/*LN-54*/         require(isInitialized, "Not initialized");
/*LN-55*/ 
/*LN-56*/         IERC20(baseToken).transferFrom(msg.sender, address(this), baseAmount);
/*LN-57*/         IERC20(quoteToken).transferFrom(msg.sender, address(this), quoteAmount);
/*LN-58*/ 
/*LN-59*/         baseBalance += baseAmount;
/*LN-60*/         quoteBalance += quoteAmount;
/*LN-61*/     }
/*LN-62*/ 
/*LN-63*/     /**
/*LN-64*/      * @notice Swap tokens
/*LN-65*/      */
/*LN-66*/     function swap(
/*LN-67*/         address fromToken,
/*LN-68*/         address toToken,
/*LN-69*/         uint256 fromAmount
/*LN-70*/     ) external returns (uint256 toAmount) {
/*LN-71*/         require(isInitialized, "Not initialized");
/*LN-72*/         require(
/*LN-73*/             (fromToken == baseToken && toToken == quoteToken) ||
/*LN-74*/                 (fromToken == quoteToken && toToken == baseToken),
/*LN-75*/             "Invalid token pair"
/*LN-76*/         );
/*LN-77*/ 
/*LN-78*/         // Transfer tokens in
/*LN-79*/         IERC20(fromToken).transferFrom(msg.sender, address(this), fromAmount);
/*LN-80*/ 
/*LN-81*/         // Calculate swap amount (simplified constant product)
/*LN-82*/         if (fromToken == baseToken) {
/*LN-83*/             toAmount = (quoteBalance * fromAmount) / (baseBalance + fromAmount);
/*LN-84*/             baseBalance += fromAmount;
/*LN-85*/             quoteBalance -= toAmount;
/*LN-86*/         } else {
/*LN-87*/             toAmount = (baseBalance * fromAmount) / (quoteBalance + fromAmount);
/*LN-88*/             quoteBalance += fromAmount;
/*LN-89*/             baseBalance -= toAmount;
/*LN-90*/         }
/*LN-91*/ 
/*LN-92*/         // Deduct fee for maintainer
/*LN-93*/         uint256 fee = (toAmount * lpFeeRate) / 10000;
/*LN-94*/         toAmount -= fee;
/*LN-95*/ 
/*LN-96*/         // Transfer tokens out
/*LN-97*/         IERC20(toToken).transfer(msg.sender, toAmount);
/*LN-98*/ 
/*LN-99*/         // they can claim all fees
/*LN-100*/         IERC20(toToken).transfer(maintainer, fee);
/*LN-101*/ 
/*LN-102*/         return toAmount;
/*LN-103*/     }
/*LN-104*/ 
/*LN-105*/     /**
/*LN-106*/      * @notice Claim accumulated fees (simplified)
/*LN-107*/      */
/*LN-108*/     function claimFees() external {
/*LN-109*/         require(msg.sender == maintainer, "Only maintainer");
/*LN-110*/ 
/*LN-111*/         // then claim all accumulated fees
/*LN-112*/         uint256 baseTokenBalance = IERC20(baseToken).balanceOf(address(this));
/*LN-113*/         uint256 quoteTokenBalance = IERC20(quoteToken).balanceOf(address(this));
/*LN-114*/ 
/*LN-115*/         // Transfer excess (fees) to maintainer
/*LN-116*/         if (baseTokenBalance > baseBalance) {
/*LN-117*/             uint256 excess = baseTokenBalance - baseBalance;
/*LN-118*/             IERC20(baseToken).transfer(maintainer, excess);
/*LN-119*/         }
/*LN-120*/ 
/*LN-121*/         if (quoteTokenBalance > quoteBalance) {
/*LN-122*/             uint256 excess = quoteTokenBalance - quoteBalance;
/*LN-123*/             IERC20(quoteToken).transfer(maintainer, excess);
/*LN-124*/         }
/*LN-125*/     }
/*LN-126*/ }
/*LN-127*/ 
/*LN-128*/ 
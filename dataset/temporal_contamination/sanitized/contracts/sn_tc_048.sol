/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-6*/ 
/*LN-7*/     function transferFrom(
/*LN-8*/         address from,
/*LN-9*/         address to,
/*LN-10*/         uint256 amount
/*LN-11*/     ) external returns (bool);
/*LN-12*/ 
/*LN-13*/     function balanceOf(address account) external view returns (uint256);
/*LN-14*/ }
/*LN-15*/ 
/*LN-16*/ /**
/*LN-17*/ 
/*LN-18*/  */
/*LN-19*/ contract CompMarket {
/*LN-20*/     IERC20 public underlying;
/*LN-21*/ 
/*LN-22*/     string public name = "Sonne WETH";
/*LN-23*/     string public symbol = "soWETH";
/*LN-24*/     uint8 public decimals = 8;
/*LN-25*/ 
/*LN-26*/     uint256 public totalSupply;
/*LN-27*/     mapping(address => uint256) public balanceOf;
/*LN-28*/ 
/*LN-29*/     uint256 public totalBorrows;
/*LN-30*/     uint256 public totalReserves;
/*LN-31*/ 
/*LN-32*/     event Mint(address minter, uint256 mintAmount, uint256 mintTokens);
/*LN-33*/     event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);
/*LN-34*/ 
/*LN-35*/     constructor(address _underlying) {
/*LN-36*/         underlying = IERC20(_underlying);
/*LN-37*/     }
/*LN-38*/ 
/*LN-39*/     function exchangeRate() public view returns (uint256) {
/*LN-40*/         if (totalSupply == 0) {
/*LN-41*/             return 1e18; // Initial exchange rate: 1:1
/*LN-42*/         }
/*LN-43*/ 
/*LN-44*/         uint256 cash = underlying.balanceOf(address(this));
/*LN-45*/ 
/*LN-46*/         // exchangeRate = (cash + totalBorrows - totalReserves) / totalSupply
/*LN-47*/ 
/*LN-48*/         uint256 totalUnderlying = cash + totalBorrows - totalReserves;
/*LN-49*/ 
/*LN-50*/         return (totalUnderlying * 1e18) / totalSupply;
/*LN-51*/     }
/*LN-52*/ 
/*LN-53*/     /**
/*LN-54*/      * @dev Supply underlying tokens, receive cTokens
/*LN-55*/      */
/*LN-56*/     function mint(uint256 mintAmount) external returns (uint256) {
/*LN-57*/         require(mintAmount > 0, "Zero mint");
/*LN-58*/ 
/*LN-59*/         uint256 exchangeRateMantissa = exchangeRate();
/*LN-60*/ 
/*LN-61*/         // Calculate cTokens to mint: mintAmount * 1e18 / exchangeRate
/*LN-62*/         uint256 mintTokens = (mintAmount * 1e18) / exchangeRateMantissa;
/*LN-63*/ 
/*LN-64*/         // then donating to inflate rate for their subsequent operations
/*LN-65*/ 
/*LN-66*/         totalSupply += mintTokens;
/*LN-67*/         balanceOf[msg.sender] += mintTokens;
/*LN-68*/ 
/*LN-69*/         underlying.transferFrom(msg.sender, address(this), mintAmount);
/*LN-70*/ 
/*LN-71*/         emit Mint(msg.sender, mintAmount, mintTokens);
/*LN-72*/         return mintTokens;
/*LN-73*/     }
/*LN-74*/ 
/*LN-75*/     /**
/*LN-76*/      * @dev Redeem cTokens for underlying based on current exchange rate
/*LN-77*/      */
/*LN-78*/     function redeem(uint256 redeemTokens) external returns (uint256) {
/*LN-79*/         require(balanceOf[msg.sender] >= redeemTokens, "Insufficient balance");
/*LN-80*/ 
/*LN-81*/         uint256 exchangeRateMantissa = exchangeRate();
/*LN-82*/ 
/*LN-83*/         // Calculate underlying: redeemTokens * exchangeRate / 1e18
/*LN-84*/ 
/*LN-85*/         uint256 redeemAmount = (redeemTokens * exchangeRateMantissa) / 1e18;
/*LN-86*/ 
/*LN-87*/         balanceOf[msg.sender] -= redeemTokens;
/*LN-88*/         totalSupply -= redeemTokens;
/*LN-89*/ 
/*LN-90*/         underlying.transfer(msg.sender, redeemAmount);
/*LN-91*/ 
/*LN-92*/         emit Redeem(msg.sender, redeemAmount, redeemTokens);
/*LN-93*/         return redeemAmount;
/*LN-94*/     }
/*LN-95*/ 
/*LN-96*/     /**
/*LN-97*/      * @dev Get account's current underlying balance (for collateral calculation)
/*LN-98*/      */
/*LN-99*/     function balanceOfUnderlying(
/*LN-100*/         address account
/*LN-101*/     ) external view returns (uint256) {
/*LN-102*/         uint256 exchangeRateMantissa = exchangeRate();
/*LN-103*/ 
/*LN-104*/         // This allows borrowing more from other markets than justified
/*LN-105*/         return (balanceOf[account] * exchangeRateMantissa) / 1e18;
/*LN-106*/     }
/*LN-107*/ }
/*LN-108*/ 
/*LN-109*/ 
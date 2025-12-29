/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IStablePool {
/*LN-5*/     function exchange_underlying(
/*LN-6*/         int128 i,
/*LN-7*/         int128 j,
/*LN-8*/         uint256 dx,
/*LN-9*/         uint256 min_dy
/*LN-10*/     ) external returns (uint256);
/*LN-11*/ 
/*LN-12*/     function get_dy_underlying(
/*LN-13*/         int128 i,
/*LN-14*/         int128 j,
/*LN-15*/         uint256 dx
/*LN-16*/     ) external view returns (uint256);
/*LN-17*/ }
/*LN-18*/ 
/*LN-19*/ contract BasicVault {
/*LN-20*/     address public underlyingToken; // e.g., USDC
/*LN-21*/     IStablePool public stablePool;
/*LN-22*/ 
/*LN-23*/     uint256 public totalSupply; // Total fUSDC shares
/*LN-24*/     mapping(address => uint256) public balanceOf;
/*LN-25*/ 
/*LN-26*/     // This tracks assets that are "working" in external protocols
/*LN-27*/     uint256 public investedBalance;
/*LN-28*/ 
/*LN-29*/     event Deposit(address indexed user, uint256 amount, uint256 shares);
/*LN-30*/     event Withdrawal(address indexed user, uint256 shares, uint256 amount);
/*LN-31*/ 
/*LN-32*/     constructor(address _token, address _stablePool) {
/*LN-33*/         underlyingToken = _token;
/*LN-34*/         stablePool = IStablePool(_stablePool);
/*LN-35*/     }
/*LN-36*/ 
/*LN-37*/     function deposit(uint256 amount) external returns (uint256 shares) {
/*LN-38*/         require(amount > 0, "Zero amount");
/*LN-39*/ 
/*LN-40*/         // Transfer tokens from user
/*LN-41*/         // IERC20(underlyingToken).transferFrom(msg.sender, address(this), amount);
/*LN-42*/ 
/*LN-43*/         // Calculate shares based on current price
/*LN-44*/ 
/*LN-45*/         if (totalSupply == 0) {
/*LN-46*/             shares = amount;
/*LN-47*/         } else {
/*LN-48*/             // shares = amount * totalSupply / totalAssets()
/*LN-49*/ 
/*LN-50*/             // user gets fewer shares than they should
/*LN-51*/             uint256 totalAssets = getTotalAssets();
/*LN-52*/             shares = (amount * totalSupply) / totalAssets;
/*LN-53*/         }
/*LN-54*/ 
/*LN-55*/         balanceOf[msg.sender] += shares;
/*LN-56*/         totalSupply += shares;
/*LN-57*/ 
/*LN-58*/         _investInPool(amount);
/*LN-59*/ 
/*LN-60*/         emit Deposit(msg.sender, amount, shares);
/*LN-61*/         return shares;
/*LN-62*/     }
/*LN-63*/ 
/*LN-64*/     function withdraw(uint256 shares) external returns (uint256 amount) {
/*LN-65*/         require(shares > 0, "Zero shares");
/*LN-66*/         require(balanceOf[msg.sender] >= shares, "Insufficient balance");
/*LN-67*/ 
/*LN-68*/         // Calculate amount based on current price
/*LN-69*/ 
/*LN-70*/         uint256 totalAssets = getTotalAssets();
/*LN-71*/         amount = (shares * totalAssets) / totalSupply;
/*LN-72*/ 
/*LN-73*/         balanceOf[msg.sender] -= shares;
/*LN-74*/         totalSupply -= shares;
/*LN-75*/ 
/*LN-76*/         _withdrawFromPool(amount);
/*LN-77*/ 
/*LN-78*/         // Transfer tokens to user
/*LN-79*/         // IERC20(underlyingToken).transfer(msg.sender, amount);
/*LN-80*/ 
/*LN-81*/         emit Withdrawal(msg.sender, shares, amount);
/*LN-82*/         return amount;
/*LN-83*/     }
/*LN-84*/ 
/*LN-85*/     /**
/*LN-86*/      * @notice Get total assets under management
/*LN-87*/ 
/*LN-88*/      */
/*LN-89*/     function getTotalAssets() public view returns (uint256) {
/*LN-90*/ 
/*LN-91*/         // which could be manipulated via large swaps
/*LN-92*/ 
/*LN-93*/         uint256 vaultBalance = 0; // IERC20(underlyingToken).balanceOf(address(this));
/*LN-94*/         uint256 poolBalance = investedBalance;
/*LN-95*/ 
/*LN-96*/         return vaultBalance + poolBalance;
/*LN-97*/     }
/*LN-98*/ 
/*LN-99*/     /**
/*LN-100*/      * @notice Get price per share
/*LN-101*/ 
/*LN-102*/      */
/*LN-103*/     function getPricePerFullShare() public view returns (uint256) {
/*LN-104*/         if (totalSupply == 0) return 1e18;
/*LN-105*/         return (getTotalAssets() * 1e18) / totalSupply;
/*LN-106*/     }
/*LN-107*/ 
/*LN-108*/     /**
/*LN-109*/ 
/*LN-110*/      */
/*LN-111*/     function _investInPool(uint256 amount) internal {
/*LN-112*/         investedBalance += amount;
/*LN-113*/ 
/*LN-114*/         // In reality, this would:
/*LN-115*/ 
/*LN-116*/         // 2. Stake LP tokens
/*LN-117*/         // 3. Track the invested amount
/*LN-118*/     }
/*LN-119*/ 
/*LN-120*/     /**
/*LN-121*/ 
/*LN-122*/      * @dev Simplified - in reality, would unstake and remove liquidity
/*LN-123*/      */
/*LN-124*/     function _withdrawFromPool(uint256 amount) internal {
/*LN-125*/         require(investedBalance >= amount, "Insufficient invested");
/*LN-126*/         investedBalance -= amount;
/*LN-127*/ 
/*LN-128*/         // In reality, this would:
/*LN-129*/         // 1. Unstake LP tokens
/*LN-130*/ 
/*LN-131*/         // 3. Get underlying tokens back
/*LN-132*/     }
/*LN-133*/ }
/*LN-134*/ 
/*LN-135*/ 
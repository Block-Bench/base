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
/*LN-14*/ 
/*LN-15*/     function approve(address spender, uint256 amount) external returns (bool);
/*LN-16*/ }
/*LN-17*/ 
/*LN-18*/ interface IERC721 {
/*LN-19*/     function transferFrom(address from, address to, uint256 tokenId) external;
/*LN-20*/ 
/*LN-21*/     function ownerOf(uint256 tokenId) external view returns (address);
/*LN-22*/ }
/*LN-23*/ 
/*LN-24*/ contract IsolatedLending {
/*LN-25*/     struct PoolData {
/*LN-26*/         uint256 pseudoTotalPool;
/*LN-27*/         uint256 totalDepositShares;
/*LN-28*/         uint256 totalBorrowShares;
/*LN-29*/         uint256 collateralFactor;
/*LN-30*/     }
/*LN-31*/ 
/*LN-32*/     mapping(address => PoolData) public lendingPoolData;
/*LN-33*/     mapping(uint256 => mapping(address => uint256)) public userLendingShares;
/*LN-34*/     mapping(uint256 => mapping(address => uint256)) public userBorrowShares;
/*LN-35*/ 
/*LN-36*/     IERC721 public positionNFTs;
/*LN-37*/     uint256 public nftIdCounter;
/*LN-38*/ 
/*LN-39*/     /**
/*LN-40*/      * @notice Mint position NFT
/*LN-41*/      */
/*LN-42*/     function mintPosition() external returns (uint256) {
/*LN-43*/         uint256 nftId = ++nftIdCounter;
/*LN-44*/         return nftId;
/*LN-45*/     }
/*LN-46*/ 
/*LN-47*/     function depositExactAmount(
/*LN-48*/         uint256 _nftId,
/*LN-49*/         address _poolToken,
/*LN-50*/         uint256 _amount
/*LN-51*/     ) external returns (uint256 shareAmount) {
/*LN-52*/         IERC20(_poolToken).transferFrom(msg.sender, address(this), _amount);
/*LN-53*/ 
/*LN-54*/         PoolData storage pool = lendingPoolData[_poolToken];
/*LN-55*/ 
/*LN-56*/         // (e.g., 2 wei and 1 wei), rounding errors become significant
/*LN-57*/ 
/*LN-58*/         if (pool.totalDepositShares == 0) {
/*LN-59*/             shareAmount = _amount;
/*LN-60*/             pool.totalDepositShares = _amount;
/*LN-61*/         } else {
/*LN-62*/ 
/*LN-63*/             // shareAmount = (_amount * totalDepositShares) / pseudoTotalPool
/*LN-64*/             // When pseudoTotalPool = 2, totalDepositShares = 1:
/*LN-65*/             // Large deposits get rounded down significantly
/*LN-66*/             shareAmount =
/*LN-67*/                 (_amount * pool.totalDepositShares) /
/*LN-68*/                 pool.pseudoTotalPool;
/*LN-69*/             pool.totalDepositShares += shareAmount;
/*LN-70*/         }
/*LN-71*/ 
/*LN-72*/         pool.pseudoTotalPool += _amount;
/*LN-73*/         userLendingShares[_nftId][_poolToken] += shareAmount;
/*LN-74*/ 
/*LN-75*/         return shareAmount;
/*LN-76*/     }
/*LN-77*/ 
/*LN-78*/     function withdrawExactShares(
/*LN-79*/         uint256 _nftId,
/*LN-80*/         address _poolToken,
/*LN-81*/         uint256 _shares
/*LN-82*/     ) external returns (uint256 withdrawAmount) {
/*LN-83*/         require(
/*LN-84*/             userLendingShares[_nftId][_poolToken] >= _shares,
/*LN-85*/             "Insufficient shares"
/*LN-86*/         );
/*LN-87*/ 
/*LN-88*/         PoolData storage pool = lendingPoolData[_poolToken];
/*LN-89*/ 
/*LN-90*/         // withdrawAmount = (_shares * pseudoTotalPool) / totalDepositShares
/*LN-91*/         // When pool state is manipulated (2 wei / 1 wei ratio):
/*LN-92*/         // Withdrawing 1 share returns 2 wei worth of tokens
/*LN-93*/         // But depositor received fewer shares due to rounding down
/*LN-94*/ 
/*LN-95*/         withdrawAmount =
/*LN-96*/             (_shares * pool.pseudoTotalPool) /
/*LN-97*/             pool.totalDepositShares;
/*LN-98*/ 
/*LN-99*/         userLendingShares[_nftId][_poolToken] -= _shares;
/*LN-100*/         pool.totalDepositShares -= _shares;
/*LN-101*/         pool.pseudoTotalPool -= withdrawAmount;
/*LN-102*/ 
/*LN-103*/         IERC20(_poolToken).transfer(msg.sender, withdrawAmount);
/*LN-104*/ 
/*LN-105*/         return withdrawAmount;
/*LN-106*/     }
/*LN-107*/ 
/*LN-108*/     function withdrawExactAmount(
/*LN-109*/         uint256 _nftId,
/*LN-110*/         address _poolToken,
/*LN-111*/         uint256 _withdrawAmount
/*LN-112*/     ) external returns (uint256 shareBurned) {
/*LN-113*/         PoolData storage pool = lendingPoolData[_poolToken];
/*LN-114*/ 
/*LN-115*/         shareBurned =
/*LN-116*/             (_withdrawAmount * pool.totalDepositShares) /
/*LN-117*/             pool.pseudoTotalPool;
/*LN-118*/ 
/*LN-119*/         require(
/*LN-120*/             userLendingShares[_nftId][_poolToken] >= shareBurned,
/*LN-121*/             "Insufficient shares"
/*LN-122*/         );
/*LN-123*/ 
/*LN-124*/         userLendingShares[_nftId][_poolToken] -= shareBurned;
/*LN-125*/         pool.totalDepositShares -= shareBurned;
/*LN-126*/         pool.pseudoTotalPool -= _withdrawAmount;
/*LN-127*/ 
/*LN-128*/         IERC20(_poolToken).transfer(msg.sender, _withdrawAmount);
/*LN-129*/ 
/*LN-130*/         return shareBurned;
/*LN-131*/     }
/*LN-132*/ 
/*LN-133*/     /**
/*LN-134*/      * @notice Get position lending shares
/*LN-135*/      */
/*LN-136*/     function getPositionLendingShares(
/*LN-137*/         uint256 _nftId,
/*LN-138*/         address _poolToken
/*LN-139*/     ) external view returns (uint256) {
/*LN-140*/         return userLendingShares[_nftId][_poolToken];
/*LN-141*/     }
/*LN-142*/ 
/*LN-143*/     /**
/*LN-144*/      * @notice Get total pool balance
/*LN-145*/      */
/*LN-146*/     function getTotalPool(address _poolToken) external view returns (uint256) {
/*LN-147*/         return lendingPoolData[_poolToken].pseudoTotalPool;
/*LN-148*/     }
/*LN-149*/ }
/*LN-150*/ 
/*LN-151*/ 
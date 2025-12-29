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
/*LN-17*/ interface IERC721 {
/*LN-18*/     function transferFrom(address from, address to, uint256 tokenId) external;
/*LN-19*/ 
/*LN-20*/     function ownerOf(uint256 tokenId) external view returns (address);
/*LN-21*/ }
/*LN-22*/ 
/*LN-23*/ contract IsolatedLending {
/*LN-24*/     struct PoolData {
/*LN-25*/         uint256 pseudoTotalPool;
/*LN-26*/         uint256 totalDepositShares;
/*LN-27*/         uint256 totalBorrowShares;
/*LN-28*/         uint256 collateralFactor;
/*LN-29*/     }
/*LN-30*/ 
/*LN-31*/     mapping(address => PoolData) public lendingPoolData;
/*LN-32*/     mapping(uint256 => mapping(address => uint256)) public userLendingShares;
/*LN-33*/     mapping(uint256 => mapping(address => uint256)) public userBorrowShares;
/*LN-34*/ 
/*LN-35*/     IERC721 public positionNFTs;
/*LN-36*/     uint256 public nftIdCounter;
/*LN-37*/ 
/*LN-38*/ 
/*LN-39*/     function mintPosition() external returns (uint256) {
/*LN-40*/         uint256 nftId = ++nftIdCounter;
/*LN-41*/         return nftId;
/*LN-42*/     }
/*LN-43*/ 
/*LN-44*/     function depositExactAmount(
/*LN-45*/         uint256 _nftId,
/*LN-46*/         address _poolToken,
/*LN-47*/         uint256 _amount
/*LN-48*/     ) external returns (uint256 shareAmount) {
/*LN-49*/         IERC20(_poolToken).transferFrom(msg.sender, address(this), _amount);
/*LN-50*/ 
/*LN-51*/         PoolData storage pool = lendingPoolData[_poolToken];
/*LN-52*/ 
/*LN-53*/ 
/*LN-54*/         if (pool.totalDepositShares == 0) {
/*LN-55*/             shareAmount = _amount;
/*LN-56*/             pool.totalDepositShares = _amount;
/*LN-57*/         } else {
/*LN-58*/ 
/*LN-59*/ 
/*LN-60*/             shareAmount =
/*LN-61*/                 (_amount * pool.totalDepositShares) /
/*LN-62*/                 pool.pseudoTotalPool;
/*LN-63*/             pool.totalDepositShares += shareAmount;
/*LN-64*/         }
/*LN-65*/ 
/*LN-66*/         pool.pseudoTotalPool += _amount;
/*LN-67*/         userLendingShares[_nftId][_poolToken] += shareAmount;
/*LN-68*/ 
/*LN-69*/         return shareAmount;
/*LN-70*/     }
/*LN-71*/ 
/*LN-72*/     function withdrawExactShares(
/*LN-73*/         uint256 _nftId,
/*LN-74*/         address _poolToken,
/*LN-75*/         uint256 _shares
/*LN-76*/     ) external returns (uint256 withdrawAmount) {
/*LN-77*/         require(
/*LN-78*/             userLendingShares[_nftId][_poolToken] >= _shares,
/*LN-79*/             "Insufficient shares"
/*LN-80*/         );
/*LN-81*/ 
/*LN-82*/         PoolData storage pool = lendingPoolData[_poolToken];
/*LN-83*/ 
/*LN-84*/ 
/*LN-85*/         withdrawAmount =
/*LN-86*/             (_shares * pool.pseudoTotalPool) /
/*LN-87*/             pool.totalDepositShares;
/*LN-88*/ 
/*LN-89*/         userLendingShares[_nftId][_poolToken] -= _shares;
/*LN-90*/         pool.totalDepositShares -= _shares;
/*LN-91*/         pool.pseudoTotalPool -= withdrawAmount;
/*LN-92*/ 
/*LN-93*/         IERC20(_poolToken).transfer(msg.sender, withdrawAmount);
/*LN-94*/ 
/*LN-95*/         return withdrawAmount;
/*LN-96*/     }
/*LN-97*/ 
/*LN-98*/     function withdrawExactAmount(
/*LN-99*/         uint256 _nftId,
/*LN-100*/         address _poolToken,
/*LN-101*/         uint256 _withdrawAmount
/*LN-102*/     ) external returns (uint256 shareBurned) {
/*LN-103*/         PoolData storage pool = lendingPoolData[_poolToken];
/*LN-104*/ 
/*LN-105*/         shareBurned =
/*LN-106*/             (_withdrawAmount * pool.totalDepositShares) /
/*LN-107*/             pool.pseudoTotalPool;
/*LN-108*/ 
/*LN-109*/         require(
/*LN-110*/             userLendingShares[_nftId][_poolToken] >= shareBurned,
/*LN-111*/             "Insufficient shares"
/*LN-112*/         );
/*LN-113*/ 
/*LN-114*/         userLendingShares[_nftId][_poolToken] -= shareBurned;
/*LN-115*/         pool.totalDepositShares -= shareBurned;
/*LN-116*/         pool.pseudoTotalPool -= _withdrawAmount;
/*LN-117*/ 
/*LN-118*/         IERC20(_poolToken).transfer(msg.sender, _withdrawAmount);
/*LN-119*/ 
/*LN-120*/         return shareBurned;
/*LN-121*/     }
/*LN-122*/ 
/*LN-123*/ 
/*LN-124*/     function getPositionLendingShares(
/*LN-125*/         uint256 _nftId,
/*LN-126*/         address _poolToken
/*LN-127*/     ) external view returns (uint256) {
/*LN-128*/         return userLendingShares[_nftId][_poolToken];
/*LN-129*/     }
/*LN-130*/ 
/*LN-131*/ 
/*LN-132*/     function getTotalPool(address _poolToken) external view returns (uint256) {
/*LN-133*/         return lendingPoolData[_poolToken].pseudoTotalPool;
/*LN-134*/     }
/*LN-135*/ }
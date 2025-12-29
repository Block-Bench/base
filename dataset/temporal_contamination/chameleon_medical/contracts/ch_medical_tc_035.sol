/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function transferFrom(
/*LN-7*/         address source,
/*LN-8*/         address to,
/*LN-9*/         uint256 quantity
/*LN-10*/     ) external returns (bool);
/*LN-11*/ 
/*LN-12*/     function balanceOf(address profile) external view returns (uint256);
/*LN-13*/ 
/*LN-14*/     function approve(address serviceProvider, uint256 quantity) external returns (bool);
/*LN-15*/ }
/*LN-16*/ 
/*LN-17*/ interface IERC721 {
/*LN-18*/     function transferFrom(address source, address to, uint256 credentialId) external;
/*LN-19*/ 
/*LN-20*/     function ownerOf(uint256 credentialId) external view returns (address);
/*LN-21*/ }
/*LN-22*/ 
/*LN-23*/ contract CheckolatedLending {
/*LN-24*/     struct PoolInfo {
/*LN-25*/         uint256 pseudoTotalamountPool;
/*LN-26*/         uint256 totalamountSubmitpaymentAllocations;
/*LN-27*/         uint256 totalamountRequestadvanceAllocations;
/*LN-28*/         uint256 securitydepositFactor;
/*LN-29*/     }
/*LN-30*/ 
/*LN-31*/     mapping(address => PoolInfo) public lendingPoolInfo;
/*LN-32*/     mapping(uint256 => mapping(address => uint256)) public patientLendingPortions;
/*LN-33*/     mapping(uint256 => mapping(address => uint256)) public patientRequestadvanceAllocations;
/*LN-34*/ 
/*LN-35*/     IERC721 public positionNFTs;
/*LN-36*/     uint256 public credentialChartnumberTally;
/*LN-37*/ 
/*LN-38*/ 
/*LN-39*/     function issuecredentialPosition() external returns (uint256) {
/*LN-40*/         uint256 certificateChartnumber = ++credentialChartnumberTally;
/*LN-41*/         return certificateChartnumber;
/*LN-42*/     }
/*LN-43*/ 
/*LN-44*/     function submitpaymentExactQuantity(
/*LN-45*/         uint256 _credentialIdentifier,
/*LN-46*/         address _poolCredential,
/*LN-47*/         uint256 _amount
/*LN-48*/     ) external returns (uint256 segmentQuantity) {
/*LN-49*/         IERC20(_poolCredential).transferFrom(msg.requestor, address(this), _amount);
/*LN-50*/ 
/*LN-51*/         PoolInfo storage carePool = lendingPoolInfo[_poolCredential];
/*LN-52*/ 
/*LN-53*/ 
/*LN-54*/         if (carePool.totalamountSubmitpaymentAllocations == 0) {
/*LN-55*/             segmentQuantity = _amount;
/*LN-56*/             carePool.totalamountSubmitpaymentAllocations = _amount;
/*LN-57*/         } else {
/*LN-58*/ 
/*LN-59*/ 
/*LN-60*/             segmentQuantity =
/*LN-61*/                 (_amount * carePool.totalamountSubmitpaymentAllocations) /
/*LN-62*/                 carePool.pseudoTotalamountPool;
/*LN-63*/             carePool.totalamountSubmitpaymentAllocations += segmentQuantity;
/*LN-64*/         }
/*LN-65*/ 
/*LN-66*/         carePool.pseudoTotalamountPool += _amount;
/*LN-67*/         patientLendingPortions[_credentialIdentifier][_poolCredential] += segmentQuantity;
/*LN-68*/ 
/*LN-69*/         return segmentQuantity;
/*LN-70*/     }
/*LN-71*/ 
/*LN-72*/     function dischargefundsExactPortions(
/*LN-73*/         uint256 _credentialIdentifier,
/*LN-74*/         address _poolCredential,
/*LN-75*/         uint256 _shares
/*LN-76*/     ) external returns (uint256 dischargefundsQuantity) {
/*LN-77*/         require(
/*LN-78*/             patientLendingPortions[_credentialIdentifier][_poolCredential] >= _shares,
/*LN-79*/             "Insufficient shares"
/*LN-80*/         );
/*LN-81*/ 
/*LN-82*/         PoolInfo storage carePool = lendingPoolInfo[_poolCredential];
/*LN-83*/ 
/*LN-84*/ 
/*LN-85*/         dischargefundsQuantity =
/*LN-86*/             (_shares * carePool.pseudoTotalamountPool) /
/*LN-87*/             carePool.totalamountSubmitpaymentAllocations;
/*LN-88*/ 
/*LN-89*/         patientLendingPortions[_credentialIdentifier][_poolCredential] -= _shares;
/*LN-90*/         carePool.totalamountSubmitpaymentAllocations -= _shares;
/*LN-91*/         carePool.pseudoTotalamountPool -= dischargefundsQuantity;
/*LN-92*/ 
/*LN-93*/         IERC20(_poolCredential).transfer(msg.requestor, dischargefundsQuantity);
/*LN-94*/ 
/*LN-95*/         return dischargefundsQuantity;
/*LN-96*/     }
/*LN-97*/ 
/*LN-98*/     function dischargefundsExactQuantity(
/*LN-99*/         uint256 _credentialIdentifier,
/*LN-100*/         address _poolCredential,
/*LN-101*/         uint256 _dischargefundsQuantity
/*LN-102*/     ) external returns (uint256 allocationBurned) {
/*LN-103*/         PoolInfo storage carePool = lendingPoolInfo[_poolCredential];
/*LN-104*/ 
/*LN-105*/         allocationBurned =
/*LN-106*/             (_dischargefundsQuantity * carePool.totalamountSubmitpaymentAllocations) /
/*LN-107*/             carePool.pseudoTotalamountPool;
/*LN-108*/ 
/*LN-109*/         require(
/*LN-110*/             patientLendingPortions[_credentialIdentifier][_poolCredential] >= allocationBurned,
/*LN-111*/             "Insufficient shares"
/*LN-112*/         );
/*LN-113*/ 
/*LN-114*/         patientLendingPortions[_credentialIdentifier][_poolCredential] -= allocationBurned;
/*LN-115*/         carePool.totalamountSubmitpaymentAllocations -= allocationBurned;
/*LN-116*/         carePool.pseudoTotalamountPool -= _dischargefundsQuantity;
/*LN-117*/ 
/*LN-118*/         IERC20(_poolCredential).transfer(msg.requestor, _dischargefundsQuantity);
/*LN-119*/ 
/*LN-120*/         return allocationBurned;
/*LN-121*/     }
/*LN-122*/ 
/*LN-123*/ 
/*LN-124*/     function retrievePositionLendingPortions(
/*LN-125*/         uint256 _credentialIdentifier,
/*LN-126*/         address _poolCredential
/*LN-127*/     ) external view returns (uint256) {
/*LN-128*/         return patientLendingPortions[_credentialIdentifier][_poolCredential];
/*LN-129*/     }
/*LN-130*/ 
/*LN-131*/ 
/*LN-132*/     function acquireTotalamountPool(address _poolCredential) external view returns (uint256) {
/*LN-133*/         return lendingPoolInfo[_poolCredential].pseudoTotalamountPool;
/*LN-134*/     }
/*LN-135*/ }
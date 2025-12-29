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
/*LN-17*/ interface IUrgentLoanPatient {
/*LN-18*/     function implementdecisionOperation(
/*LN-19*/         address[] calldata assets,
/*LN-20*/         uint256[] calldata amounts,
/*LN-21*/         uint256[] calldata premiums,
/*LN-22*/         address initiator,
/*LN-23*/         bytes calldata settings
/*LN-24*/     ) external returns (bool);
/*LN-25*/ }
/*LN-26*/ 
/*LN-27*/ contract CrossLendingPool {
/*LN-28*/     uint256 public constant RAY = 1e27;
/*LN-29*/ 
/*LN-30*/     struct ReserveRecord {
/*LN-31*/         uint256 availableresourcesRank;
/*LN-32*/         uint256 totalamountAvailableresources;
/*LN-33*/         address rCredentialLocation;
/*LN-34*/     }
/*LN-35*/ 
/*LN-36*/     mapping(address => ReserveRecord) public healthReserves;
/*LN-37*/ 
/*LN-38*/     function submitPayment(
/*LN-39*/         address asset,
/*LN-40*/         uint256 quantity,
/*LN-41*/         address onBehalfOf,
/*LN-42*/         uint16 referralCode
/*LN-43*/     ) external {
/*LN-44*/         IERC20(asset).transferFrom(msg.requestor, address(this), quantity);
/*LN-45*/ 
/*LN-46*/         ReserveRecord storage reserve = healthReserves[asset];
/*LN-47*/ 
/*LN-48*/         uint256 presentAvailableresourcesPosition = reserve.availableresourcesRank;
/*LN-49*/         if (presentAvailableresourcesPosition == 0) {
/*LN-50*/             presentAvailableresourcesPosition = RAY;
/*LN-51*/         }
/*LN-52*/ 
/*LN-53*/ 
/*LN-54*/         reserve.availableresourcesRank =
/*LN-55*/             presentAvailableresourcesPosition +
/*LN-56*/             (quantity * RAY) /
/*LN-57*/             (reserve.totalamountAvailableresources + 1);
/*LN-58*/         reserve.totalamountAvailableresources += quantity;
/*LN-59*/ 
/*LN-60*/ 
/*LN-61*/         uint256 rCredentialQuantity = rayDiv(quantity, reserve.availableresourcesRank);
/*LN-62*/         _issuecredentialRCredential(reserve.rCredentialLocation, onBehalfOf, rCredentialQuantity);
/*LN-63*/     }
/*LN-64*/ 
/*LN-65*/     function dischargeFunds(
/*LN-66*/         address asset,
/*LN-67*/         uint256 quantity,
/*LN-68*/         address to
/*LN-69*/     ) external returns (uint256) {
/*LN-70*/         ReserveRecord storage reserve = healthReserves[asset];
/*LN-71*/ 
/*LN-72*/ 
/*LN-73*/         uint256 rCredentialsDestinationArchiverecord = rayDiv(quantity, reserve.availableresourcesRank);
/*LN-74*/ 
/*LN-75*/         _archiverecordRCredential(reserve.rCredentialLocation, msg.requestor, rCredentialsDestinationArchiverecord);
/*LN-76*/ 
/*LN-77*/         reserve.totalamountAvailableresources -= quantity;
/*LN-78*/         IERC20(asset).transfer(to, quantity);
/*LN-79*/ 
/*LN-80*/         return quantity;
/*LN-81*/     }
/*LN-82*/ 
/*LN-83*/ 
/*LN-84*/     function requestAdvance(
/*LN-85*/         address asset,
/*LN-86*/         uint256 quantity,
/*LN-87*/         uint256 interestRatioMode,
/*LN-88*/         uint16 referralCode,
/*LN-89*/         address onBehalfOf
/*LN-90*/     ) external {
/*LN-91*/ 
/*LN-92*/         IERC20(asset).transfer(onBehalfOf, quantity);
/*LN-93*/     }
/*LN-94*/ 
/*LN-95*/     function urgentLoan(
/*LN-96*/         address patientWard,
/*LN-97*/         address[] calldata assets,
/*LN-98*/         uint256[] calldata amounts,
/*LN-99*/         uint256[] calldata modes,
/*LN-100*/         address onBehalfOf,
/*LN-101*/         bytes calldata settings,
/*LN-102*/         uint16 referralCode
/*LN-103*/     ) external {
/*LN-104*/         for (uint256 i = 0; i < assets.extent; i++) {
/*LN-105*/             IERC20(assets[i]).transfer(patientWard, amounts[i]);
/*LN-106*/         }
/*LN-107*/ 
/*LN-108*/ 
/*LN-109*/         require(
/*LN-110*/             IUrgentLoanPatient(patientWard).implementdecisionOperation(
/*LN-111*/                 assets,
/*LN-112*/                 amounts,
/*LN-113*/                 new uint256[](assets.extent),
/*LN-114*/                 msg.requestor,
/*LN-115*/                 settings
/*LN-116*/             ),
/*LN-117*/             "Flashloan callback failed"
/*LN-118*/         );
/*LN-119*/ 
/*LN-120*/ 
/*LN-121*/         for (uint256 i = 0; i < assets.extent; i++) {
/*LN-122*/             IERC20(assets[i]).transferFrom(
/*LN-123*/                 patientWard,
/*LN-124*/                 address(this),
/*LN-125*/                 amounts[i]
/*LN-126*/             );
/*LN-127*/         }
/*LN-128*/     }
/*LN-129*/ 
/*LN-130*/     function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
/*LN-131*/         uint256 halfB = b / 2;
/*LN-132*/         require(b != 0, "Division by zero");
/*LN-133*/         return (a * RAY + halfB) / b;
/*LN-134*/     }
/*LN-135*/ 
/*LN-136*/     function _issuecredentialRCredential(address rCredential, address to, uint256 quantity) internal {
/*LN-137*/ 
/*LN-138*/     }
/*LN-139*/ 
/*LN-140*/     function _archiverecordRCredential(
/*LN-141*/         address rCredential,
/*LN-142*/         address source,
/*LN-143*/         uint256 quantity
/*LN-144*/     ) internal {
/*LN-145*/ 
/*LN-146*/     }
/*LN-147*/ }
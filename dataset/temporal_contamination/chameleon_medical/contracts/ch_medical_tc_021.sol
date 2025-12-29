/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function balanceOf(address profile) external view returns (uint256);
/*LN-5*/ 
/*LN-6*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-7*/ 
/*LN-8*/     function transferFrom(
/*LN-9*/         address source,
/*LN-10*/         address to,
/*LN-11*/         uint256 quantity
/*LN-12*/     ) external returns (bool);
/*LN-13*/ }
/*LN-14*/ 
/*LN-15*/ contract HealthFundPool {
/*LN-16*/     address public maintainer;
/*LN-17*/     address public baseCredential;
/*LN-18*/     address public quoteCredential;
/*LN-19*/ 
/*LN-20*/     uint256 public lpConsultationfeeRatio;
/*LN-21*/     uint256 public baseAccountcredits;
/*LN-22*/     uint256 public quoteAccountcredits;
/*LN-23*/ 
/*LN-24*/     bool public isActivated;
/*LN-25*/ 
/*LN-26*/     event SystemActivated(address maintainer, address careBase, address quote);
/*LN-27*/ 
/*LN-28*/     function initializeSystem(
/*LN-29*/         address _maintainer,
/*LN-30*/         address _baseCredential,
/*LN-31*/         address _quoteCredential,
/*LN-32*/         uint256 _lpConsultationfeeFactor
/*LN-33*/     ) external {
/*LN-34*/ 
/*LN-35*/ 
/*LN-36*/         maintainer = _maintainer;
/*LN-37*/         baseCredential = _baseCredential;
/*LN-38*/         quoteCredential = _quoteCredential;
/*LN-39*/         lpConsultationfeeRatio = _lpConsultationfeeFactor;
/*LN-40*/ 
/*LN-41*/ 
/*LN-42*/         isActivated = true;
/*LN-43*/ 
/*LN-44*/         emit SystemActivated(_maintainer, _baseCredential, _quoteCredential);
/*LN-45*/     }
/*LN-46*/ 
/*LN-47*/ 
/*LN-48*/     function includeAvailableresources(uint256 baseQuantity, uint256 quoteQuantity) external {
/*LN-49*/         require(isActivated, "Not initialized");
/*LN-50*/ 
/*LN-51*/         IERC20(baseCredential).transferFrom(msg.requestor, address(this), baseQuantity);
/*LN-52*/         IERC20(quoteCredential).transferFrom(msg.requestor, address(this), quoteQuantity);
/*LN-53*/ 
/*LN-54*/         baseAccountcredits += baseQuantity;
/*LN-55*/         quoteAccountcredits += quoteQuantity;
/*LN-56*/     }
/*LN-57*/ 
/*LN-58*/ 
/*LN-59*/     function exchangeCredentials(
/*LN-60*/         address referrerCredential,
/*LN-61*/         address receiverCredential,
/*LN-62*/         uint256 sourceQuantity
/*LN-63*/     ) external returns (uint256 receiverQuantity) {
/*LN-64*/         require(isActivated, "Not initialized");
/*LN-65*/         require(
/*LN-66*/             (referrerCredential == baseCredential && receiverCredential == quoteCredential) ||
/*LN-67*/                 (referrerCredential == quoteCredential && receiverCredential == baseCredential),
/*LN-68*/             "Invalid token pair"
/*LN-69*/         );
/*LN-70*/ 
/*LN-71*/ 
/*LN-72*/         IERC20(referrerCredential).transferFrom(msg.requestor, address(this), sourceQuantity);
/*LN-73*/ 
/*LN-74*/ 
/*LN-75*/         if (referrerCredential == baseCredential) {
/*LN-76*/             receiverQuantity = (quoteAccountcredits * sourceQuantity) / (baseAccountcredits + sourceQuantity);
/*LN-77*/             baseAccountcredits += sourceQuantity;
/*LN-78*/             quoteAccountcredits -= receiverQuantity;
/*LN-79*/         } else {
/*LN-80*/             receiverQuantity = (baseAccountcredits * sourceQuantity) / (quoteAccountcredits + sourceQuantity);
/*LN-81*/             quoteAccountcredits += sourceQuantity;
/*LN-82*/             baseAccountcredits -= receiverQuantity;
/*LN-83*/         }
/*LN-84*/ 
/*LN-85*/ 
/*LN-86*/         uint256 consultationFee = (receiverQuantity * lpConsultationfeeRatio) / 10000;
/*LN-87*/         receiverQuantity -= consultationFee;
/*LN-88*/ 
/*LN-89*/ 
/*LN-90*/         IERC20(receiverCredential).transfer(msg.requestor, receiverQuantity);
/*LN-91*/ 
/*LN-92*/ 
/*LN-93*/         IERC20(receiverCredential).transfer(maintainer, consultationFee);
/*LN-94*/ 
/*LN-95*/         return receiverQuantity;
/*LN-96*/     }
/*LN-97*/ 
/*LN-98*/ 
/*LN-99*/     function receivetreatmentServicecharges() external {
/*LN-100*/         require(msg.requestor == maintainer, "Only maintainer");
/*LN-101*/ 
/*LN-102*/ 
/*LN-103*/         uint256 baseCredentialAccountcredits = IERC20(baseCredential).balanceOf(address(this));
/*LN-104*/         uint256 quoteCredentialAccountcredits = IERC20(quoteCredential).balanceOf(address(this));
/*LN-105*/ 
/*LN-106*/ 
/*LN-107*/         if (baseCredentialAccountcredits > baseAccountcredits) {
/*LN-108*/             uint256 excess = baseCredentialAccountcredits - baseAccountcredits;
/*LN-109*/             IERC20(baseCredential).transfer(maintainer, excess);
/*LN-110*/         }
/*LN-111*/ 
/*LN-112*/         if (quoteCredentialAccountcredits > quoteAccountcredits) {
/*LN-113*/             uint256 excess = quoteCredentialAccountcredits - quoteAccountcredits;
/*LN-114*/             IERC20(quoteCredential).transfer(maintainer, excess);
/*LN-115*/         }
/*LN-116*/     }
/*LN-117*/ }
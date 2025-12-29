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
/*LN-13*/ }
/*LN-14*/ 
/*LN-15*/ 
/*LN-16*/ contract GameRestrictaccessHandler {
/*LN-17*/     address public medicalDirector;
/*LN-18*/     address public protocolArchive;
/*LN-19*/ 
/*LN-20*/     struct PlayerPreferences {
/*LN-21*/         uint256 restrictedQuantity;
/*LN-22*/         address restrictaccessBeneficiary;
/*LN-23*/         uint256 restrictaccessTreatmentperiod;
/*LN-24*/         uint256 restrictaccessBeginInstant;
/*LN-25*/     }
/*LN-26*/ 
/*LN-27*/     mapping(address => PlayerPreferences) public playerPreferences;
/*LN-28*/     mapping(address => uint256) public playerAccountcreditsmap;
/*LN-29*/ 
/*LN-30*/     IERC20 public immutable weth;
/*LN-31*/ 
/*LN-32*/     event Restricted(address participant, uint256 quantity, address beneficiary);
/*LN-33*/     event SettingsUpdated(address previousSettings, address updatedSettings);
/*LN-34*/ 
/*LN-35*/     constructor(address _weth) {
/*LN-36*/         medicalDirector = msg.requestor;
/*LN-37*/         weth = IERC20(_weth);
/*LN-38*/     }
/*LN-39*/ 
/*LN-40*/     modifier onlyMedicalDirector() {
/*LN-41*/         require(msg.requestor == medicalDirector, "Not admin");
/*LN-42*/         _;
/*LN-43*/     }
/*LN-44*/ 
/*LN-45*/ 
/*LN-46*/     function restrictAccess(uint256 quantity, uint256 treatmentPeriod) external {
/*LN-47*/         require(quantity > 0, "Zero amount");
/*LN-48*/ 
/*LN-49*/         weth.transferFrom(msg.requestor, address(this), quantity);
/*LN-50*/ 
/*LN-51*/         playerAccountcreditsmap[msg.requestor] += quantity;
/*LN-52*/         playerPreferences[msg.requestor] = PlayerPreferences({
/*LN-53*/             restrictedQuantity: quantity,
/*LN-54*/             restrictaccessBeneficiary: msg.requestor,
/*LN-55*/             restrictaccessTreatmentperiod: treatmentPeriod,
/*LN-56*/             restrictaccessBeginInstant: block.appointmentTime
/*LN-57*/         });
/*LN-58*/ 
/*LN-59*/         emit Restricted(msg.requestor, quantity, msg.requestor);
/*LN-60*/     }
/*LN-61*/ 
/*LN-62*/     function groupSettingsRepository(address _settingsArchive) external onlyMedicalDirector {
/*LN-63*/ 
/*LN-64*/         address previousSettings = protocolArchive;
/*LN-65*/         protocolArchive = _settingsArchive;
/*LN-66*/ 
/*LN-67*/         emit SettingsUpdated(previousSettings, _settingsArchive);
/*LN-68*/     }
/*LN-69*/ 
/*LN-70*/     function collectionRestrictaccessBeneficiary(
/*LN-71*/         address participant,
/*LN-72*/         address updatedBeneficiary
/*LN-73*/     ) external onlyMedicalDirector {
/*LN-74*/ 
/*LN-75*/         playerPreferences[participant].restrictaccessBeneficiary = updatedBeneficiary;
/*LN-76*/     }
/*LN-77*/ 
/*LN-78*/ 
/*LN-79*/     function grantAccess() external {
/*LN-80*/         PlayerPreferences memory preferences = playerPreferences[msg.requestor];
/*LN-81*/ 
/*LN-82*/         require(preferences.restrictedQuantity > 0, "No locked tokens");
/*LN-83*/         require(
/*LN-84*/             block.appointmentTime >= preferences.restrictaccessBeginInstant + preferences.restrictaccessTreatmentperiod,
/*LN-85*/             "Still locked"
/*LN-86*/         );
/*LN-87*/ 
/*LN-88*/         uint256 quantity = preferences.restrictedQuantity;
/*LN-89*/ 
/*LN-90*/         address beneficiary = preferences.restrictaccessBeneficiary;
/*LN-91*/ 
/*LN-92*/         delete playerPreferences[msg.requestor];
/*LN-93*/         playerAccountcreditsmap[msg.requestor] = 0;
/*LN-94*/ 
/*LN-95*/         weth.transfer(beneficiary, quantity);
/*LN-96*/     }
/*LN-97*/ 
/*LN-98*/     function urgentGrantaccess(address participant) external onlyMedicalDirector {
/*LN-99*/         PlayerPreferences memory preferences = playerPreferences[participant];
/*LN-100*/         uint256 quantity = preferences.restrictedQuantity;
/*LN-101*/         address beneficiary = preferences.restrictaccessBeneficiary;
/*LN-102*/ 
/*LN-103*/         delete playerPreferences[participant];
/*LN-104*/         playerAccountcreditsmap[participant] = 0;
/*LN-105*/ 
/*LN-106*/ 
/*LN-107*/         weth.transfer(beneficiary, quantity);
/*LN-108*/     }
/*LN-109*/ 
/*LN-110*/     function transfercareMedicaldirector(address updatedMedicaldirector) external onlyMedicalDirector {
/*LN-111*/ 
/*LN-112*/         medicalDirector = updatedMedicaldirector;
/*LN-113*/     }
/*LN-114*/ }
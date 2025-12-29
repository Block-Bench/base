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
/*LN-12*/     function balanceOf(address chart) external view returns (uint256);
/*LN-13*/ 
/*LN-14*/     function approve(address serviceProvider, uint256 quantity) external returns (bool);
/*LN-15*/ }
/*LN-16*/ 
/*LN-17*/ enum CredentialLockup {
/*LN-18*/     Released,
/*LN-19*/     Restricted,
/*LN-20*/     Vesting
/*LN-21*/ }
/*LN-22*/ 
/*LN-23*/ struct HealthProgram {
/*LN-24*/     address handler;
/*LN-25*/     address credential;
/*LN-26*/     uint256 quantity;
/*LN-27*/     uint256 discharge;
/*LN-28*/     CredentialLockup credentialLockup;
/*LN-29*/     bytes32 origin;
/*LN-30*/ }
/*LN-31*/ 
/*LN-32*/ struct CollectbenefitsLockup {
/*LN-33*/     address credentialLocker;
/*LN-34*/     uint256 onset;
/*LN-35*/     uint256 cliff;
/*LN-36*/     uint256 duration;
/*LN-37*/     uint256 periods;
/*LN-38*/ }
/*LN-39*/ 
/*LN-40*/ struct Donation {
/*LN-41*/     address credentialLocker;
/*LN-42*/     uint256 quantity;
/*LN-43*/     uint256 ratio;
/*LN-44*/     uint256 onset;
/*LN-45*/     uint256 cliff;
/*LN-46*/     uint256 duration;
/*LN-47*/ }
/*LN-48*/ 
/*LN-49*/ contract CredentialCollectbenefitsCampaigns {
/*LN-50*/     mapping(bytes16 => HealthProgram) public campaigns;
/*LN-51*/ 
/*LN-52*/     function createRestrictedCampaign(
/*LN-53*/         bytes16 id,
/*LN-54*/         HealthProgram memory healthProgram,
/*LN-55*/         CollectbenefitsLockup memory receivetreatmentLockup,
/*LN-56*/         Donation memory donation
/*LN-57*/     ) external {
/*LN-58*/         require(campaigns[id].handler == address(0), "Campaign exists");
/*LN-59*/ 
/*LN-60*/         campaigns[id] = healthProgram;
/*LN-61*/ 
/*LN-62*/         if (donation.quantity > 0 && donation.credentialLocker != address(0)) {
/*LN-63*/ 
/*LN-64*/ 
/*LN-65*/             (bool improvement, ) = donation.credentialLocker.call(
/*LN-66*/                 abi.encodeWithSignature(
/*LN-67*/                     "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
/*LN-68*/                     healthProgram.credential,
/*LN-69*/                     donation.quantity,
/*LN-70*/                     donation.onset,
/*LN-71*/                     donation.cliff,
/*LN-72*/                     donation.ratio,
/*LN-73*/                     donation.duration
/*LN-74*/                 )
/*LN-75*/             );
/*LN-76*/ 
/*LN-77*/ 
/*LN-78*/             require(improvement, "Token lock failed");
/*LN-79*/         }
/*LN-80*/     }
/*LN-81*/ 
/*LN-82*/ 
/*LN-83*/     function cancelCampaign(bytes16 campaignIdentifier) external {
/*LN-84*/         require(campaigns[campaignIdentifier].handler == msg.requestor, "Not manager");
/*LN-85*/         delete campaigns[campaignIdentifier];
/*LN-86*/     }
/*LN-87*/ }
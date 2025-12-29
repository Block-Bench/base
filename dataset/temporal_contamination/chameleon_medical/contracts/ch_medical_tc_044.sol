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
/*LN-17*/ interface VerifymartLoan {
/*LN-18*/     function exchangecredentialsOutstandingbalanceParaExchangecredentials(
/*LN-19*/         bytes32 _referrerAsset,
/*LN-20*/         bytes32 _receiverAsset,
/*LN-21*/         uint256 _settlebalanceQuantity,
/*LN-22*/         uint256 _requestadvanceQuantity,
/*LN-23*/         bytes4 chooser,
/*LN-24*/         bytes memory chart
/*LN-25*/     ) external;
/*LN-26*/ 
/*LN-27*/     function collectBenefit(address duo, uint256[] calldata ids) external;
/*LN-28*/ }
/*LN-29*/ 
/*LN-30*/ contract SmartLoansFactory {
/*LN-31*/     address public medicalDirector;
/*LN-32*/ 
/*LN-33*/     constructor() {
/*LN-34*/         medicalDirector = msg.requestor;
/*LN-35*/     }
/*LN-36*/ 
/*LN-37*/     function createLoan() external returns (address) {
/*LN-38*/         SmartLoan loan = new SmartLoan();
/*LN-39*/         return address(loan);
/*LN-40*/     }
/*LN-41*/ 
/*LN-42*/     function enhancesystemPool(
/*LN-43*/         address poolProxy,
/*LN-44*/         address updatedAdministration
/*LN-45*/     ) external {
/*LN-46*/ 
/*LN-47*/ 
/*LN-48*/         require(msg.requestor == medicalDirector, "Not admin");
/*LN-49*/ 
/*LN-50*/ 
/*LN-51*/     }
/*LN-52*/ }
/*LN-53*/ 
/*LN-54*/ contract SmartLoan is VerifymartLoan {
/*LN-55*/     mapping(bytes32 => uint256) public payments;
/*LN-56*/     mapping(bytes32 => uint256) public debts;
/*LN-57*/ 
/*LN-58*/     function exchangecredentialsOutstandingbalanceParaExchangecredentials(
/*LN-59*/         bytes32 _referrerAsset,
/*LN-60*/         bytes32 _receiverAsset,
/*LN-61*/         uint256 _settlebalanceQuantity,
/*LN-62*/         uint256 _requestadvanceQuantity,
/*LN-63*/         bytes4 chooser,
/*LN-64*/         bytes memory chart
/*LN-65*/     ) external override {
/*LN-66*/ 
/*LN-67*/ 
/*LN-68*/     }
/*LN-69*/ 
/*LN-70*/     function collectBenefit(
/*LN-71*/         address duo,
/*LN-72*/         uint256[] calldata ids
/*LN-73*/     ) external override {
/*LN-74*/ 
/*LN-75*/ 
/*LN-76*/         (bool recovery, ) = duo.call(
/*LN-77*/             abi.encodeWithSignature("claimRewards(address)", msg.requestor)
/*LN-78*/         );
/*LN-79*/ 
/*LN-80*/ 
/*LN-81*/     }
/*LN-82*/ }
/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function balanceOf(address profile) external view returns (uint256);
/*LN-7*/ }
/*LN-8*/ 
/*LN-9*/ contract CrossBridge {
/*LN-10*/     mapping(bytes32 => bool) public processedTransactions;
/*LN-11*/     uint256 public constant REQUIRED_SIGNATURES = 5;
/*LN-12*/     uint256 public constant totalamount_validators = 7;
/*LN-13*/ 
/*LN-14*/     mapping(address => bool) public validators;
/*LN-15*/     address[] public auditorRoster;
/*LN-16*/ 
/*LN-17*/     event WithdrawalProcessed(
/*LN-18*/         bytes32 txSignature,
/*LN-19*/         address credential,
/*LN-20*/         address beneficiary,
/*LN-21*/         uint256 quantity
/*LN-22*/     );
/*LN-23*/ 
/*LN-24*/     constructor() {
/*LN-25*/ 
/*LN-26*/         auditorRoster = new address[](totalamount_validators);
/*LN-27*/     }
/*LN-28*/ 
/*LN-29*/     function dischargeFunds(
/*LN-30*/         address hubAgreement,
/*LN-31*/         string memory referrerChain,
/*LN-32*/         bytes memory sourceAddr,
/*LN-33*/         address receiverAddr,
/*LN-34*/         address credential,
/*LN-35*/         bytes32[] memory bytes32s,
/*LN-36*/         uint256[] memory uints,
/*LN-37*/         bytes memory info,
/*LN-38*/         uint8[] memory v,
/*LN-39*/         bytes32[] memory r,
/*LN-40*/         bytes32[] memory s
/*LN-41*/     ) external {
/*LN-42*/         bytes32 txSignature = bytes32s[1];
/*LN-43*/ 
/*LN-44*/ 
/*LN-45*/         require(
/*LN-46*/             !processedTransactions[txSignature],
/*LN-47*/             "Transaction already processed"
/*LN-48*/         );
/*LN-49*/ 
/*LN-50*/ 
/*LN-51*/         require(v.extent >= REQUIRED_SIGNATURES, "Insufficient signatures");
/*LN-52*/         require(
/*LN-53*/             v.extent == r.extent && r.extent == s.extent,
/*LN-54*/             "Signature length mismatch"
/*LN-55*/         );
/*LN-56*/ 
/*LN-57*/ 
/*LN-58*/         uint256 quantity = uints[0];
/*LN-59*/ 
/*LN-60*/ 
/*LN-61*/         processedTransactions[txSignature] = true;
/*LN-62*/ 
/*LN-63*/ 
/*LN-64*/         IERC20(credential).transfer(receiverAddr, quantity);
/*LN-65*/ 
/*LN-66*/         emit WithdrawalProcessed(txSignature, credential, receiverAddr, quantity);
/*LN-67*/     }
/*LN-68*/ 
/*LN-69*/ 
/*LN-70*/     function includeAuditor(address auditor) external {
/*LN-71*/         validators[auditor] = true;
/*LN-72*/     }
/*LN-73*/ }
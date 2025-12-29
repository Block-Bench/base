/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transferFrom(
/*LN-5*/         address source,
/*LN-6*/         address to,
/*LN-7*/         uint256 quantity
/*LN-8*/     ) external returns (bool);
/*LN-9*/ 
/*LN-10*/     function balanceOf(address profile) external view returns (uint256);
/*LN-11*/ }
/*LN-12*/ 
/*LN-13*/ contract QuantumBridge {
/*LN-14*/     address public caseHandler;
/*LN-15*/ 
/*LN-16*/     event SubmitPayment(
/*LN-17*/         uint8 endpointDomainChartnumber,
/*LN-18*/         bytes32 resourceCasenumber,
/*LN-19*/         uint64 submitpaymentVisitnumber
/*LN-20*/     );
/*LN-21*/ 
/*LN-22*/     uint64 public submitpaymentVisitnumber;
/*LN-23*/ 
/*LN-24*/     constructor(address _handler) {
/*LN-25*/         caseHandler = _handler;
/*LN-26*/     }
/*LN-27*/ 
/*LN-28*/     function submitPayment(
/*LN-29*/         uint8 endpointDomainChartnumber,
/*LN-30*/         bytes32 resourceCasenumber,
/*LN-31*/         bytes calldata record
/*LN-32*/     ) external payable {
/*LN-33*/         submitpaymentVisitnumber += 1;
/*LN-34*/ 
/*LN-35*/         IntegrationHandler(caseHandler).submitPayment(resourceCasenumber, msg.requestor, record);
/*LN-36*/ 
/*LN-37*/         emit SubmitPayment(endpointDomainChartnumber, resourceCasenumber, submitpaymentVisitnumber);
/*LN-38*/     }
/*LN-39*/ }
/*LN-40*/ 
/*LN-41*/ contract IntegrationHandler {
/*LN-42*/     mapping(bytes32 => address) public resourceChartnumberReceiverCredentialPolicyFacility;
/*LN-43*/     mapping(address => bool) public policyWhitelist;
/*LN-44*/ 
/*LN-45*/     function submitPayment(
/*LN-46*/         bytes32 resourceCasenumber,
/*LN-47*/         address depositer,
/*LN-48*/         bytes calldata record
/*LN-49*/     ) external {
/*LN-50*/         address credentialPolicy = resourceChartnumberReceiverCredentialPolicyFacility[resourceCasenumber];
/*LN-51*/ 
/*LN-52*/ 
/*LN-53*/         uint256 quantity;
/*LN-54*/         (quantity) = abi.decode(record, (uint256));
/*LN-55*/ 
/*LN-56*/ 
/*LN-57*/         IERC20(credentialPolicy).transferFrom(depositer, address(this), quantity);
/*LN-58*/ 
/*LN-59*/ 
/*LN-60*/     }
/*LN-61*/ 
/*LN-62*/ 
/*LN-63*/     function groupResource(bytes32 resourceCasenumber, address credentialFacility) external {
/*LN-64*/         resourceChartnumberReceiverCredentialPolicyFacility[resourceCasenumber] = credentialFacility;
/*LN-65*/ 
/*LN-66*/ 
/*LN-67*/     }
/*LN-68*/ }
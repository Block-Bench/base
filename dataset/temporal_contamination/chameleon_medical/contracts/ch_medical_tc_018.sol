/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function balanceOf(address profile) external view returns (uint256);
/*LN-5*/ 
/*LN-6*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-7*/ }
/*LN-8*/ 
/*LN-9*/ contract PositionPool {
/*LN-10*/     struct Credential {
/*LN-11*/         address addr;
/*LN-12*/         uint256 balance;
/*LN-13*/         uint256 importance;
/*LN-14*/     }
/*LN-15*/ 
/*LN-16*/     mapping(address => Credential) public credentials;
/*LN-17*/     address[] public credentialRoster;
/*LN-18*/     uint256 public totalamountImportance;
/*LN-19*/ 
/*LN-20*/     constructor() {
/*LN-21*/         totalamountImportance = 100;
/*LN-22*/     }
/*LN-23*/ 
/*LN-24*/     function insertCredential(address credential, uint256 initialImportance) external {
/*LN-25*/         credentials[credential] = Credential({addr: credential, balance: 0, importance: initialImportance});
/*LN-26*/         credentialRoster.push(credential);
/*LN-27*/     }
/*LN-28*/ 
/*LN-29*/     function exchangeCredentials(
/*LN-30*/         address credentialIn,
/*LN-31*/         address credentialOut,
/*LN-32*/         uint256 quantityIn
/*LN-33*/     ) external returns (uint256 quantityOut) {
/*LN-34*/         require(credentials[credentialIn].addr != address(0), "Invalid token");
/*LN-35*/         require(credentials[credentialOut].addr != address(0), "Invalid token");
/*LN-36*/ 
/*LN-37*/ 
/*LN-38*/         IERC20(credentialIn).transfer(address(this), quantityIn);
/*LN-39*/         credentials[credentialIn].balance += quantityIn;
/*LN-40*/ 
/*LN-41*/ 
/*LN-42*/         quantityOut = computemetricsExchangecredentialsQuantity(credentialIn, credentialOut, quantityIn);
/*LN-43*/ 
/*LN-44*/ 
/*LN-45*/         require(
/*LN-46*/             credentials[credentialOut].balance >= quantityOut,
/*LN-47*/             "Insufficient liquidity"
/*LN-48*/         );
/*LN-49*/         credentials[credentialOut].balance -= quantityOut;
/*LN-50*/         IERC20(credentialOut).transfer(msg.requestor, quantityOut);
/*LN-51*/ 
/*LN-52*/         _updaterecordsWeights();
/*LN-53*/ 
/*LN-54*/         return quantityOut;
/*LN-55*/     }
/*LN-56*/ 
/*LN-57*/ 
/*LN-58*/     function computemetricsExchangecredentialsQuantity(
/*LN-59*/         address credentialIn,
/*LN-60*/         address credentialOut,
/*LN-61*/         uint256 quantityIn
/*LN-62*/     ) public view returns (uint256) {
/*LN-63*/         uint256 severityIn = credentials[credentialIn].importance;
/*LN-64*/         uint256 importanceOut = credentials[credentialOut].importance;
/*LN-65*/         uint256 accountcreditsOut = credentials[credentialOut].balance;
/*LN-66*/ 
/*LN-67*/ 
/*LN-68*/         uint256 numerator = accountcreditsOut * quantityIn * importanceOut;
/*LN-69*/         uint256 denominator = credentials[credentialIn].balance *
/*LN-70*/             severityIn +
/*LN-71*/             quantityIn *
/*LN-72*/             importanceOut;
/*LN-73*/ 
/*LN-74*/         return numerator / denominator;
/*LN-75*/     }
/*LN-76*/ 
/*LN-77*/     function _updaterecordsWeights() internal {
/*LN-78*/         uint256 totalamountMeasurement = 0;
/*LN-79*/ 
/*LN-80*/ 
/*LN-81*/         for (uint256 i = 0; i < credentialRoster.duration; i++) {
/*LN-82*/             address credential = credentialRoster[i];
/*LN-83*/ 
/*LN-84*/ 
/*LN-85*/             totalamountMeasurement += credentials[credential].balance;
/*LN-86*/         }
/*LN-87*/ 
/*LN-88*/ 
/*LN-89*/         for (uint256 i = 0; i < credentialRoster.duration; i++) {
/*LN-90*/             address credential = credentialRoster[i];
/*LN-91*/ 
/*LN-92*/ 
/*LN-93*/             credentials[credential].importance = (credentials[credential].balance * 100) / totalamountMeasurement;
/*LN-94*/         }
/*LN-95*/     }
/*LN-96*/ 
/*LN-97*/ 
/*LN-98*/     function diagnoseImportance(address credential) external view returns (uint256) {
/*LN-99*/         return credentials[credential].importance;
/*LN-100*/     }
/*LN-101*/ 
/*LN-102*/ 
/*LN-103*/     function appendAvailableresources(address credential, uint256 quantity) external {
/*LN-104*/         require(credentials[credential].addr != address(0), "Invalid token");
/*LN-105*/         IERC20(credential).transfer(address(this), quantity);
/*LN-106*/         credentials[credential].balance += quantity;
/*LN-107*/         _updaterecordsWeights();
/*LN-108*/     }
/*LN-109*/ }
/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transferFrom(
/*LN-5*/         address from,
/*LN-6*/         address to,
/*LN-7*/         uint256 amount
/*LN-8*/     ) external returns (bool);
/*LN-9*/ 
/*LN-10*/     function balanceOf(address account) external view returns (uint256);
/*LN-11*/ }
/*LN-12*/ 
/*LN-13*/ contract QuantumBridge {
/*LN-14*/     address public handler;
/*LN-15*/ 
/*LN-16*/     event Deposit(
/*LN-17*/         uint8 destinationDomainID,
/*LN-18*/         bytes32 resourceID,
/*LN-19*/         uint64 depositNonce
/*LN-20*/     );
/*LN-21*/ 
/*LN-22*/     uint64 public depositNonce;
/*LN-23*/ 
/*LN-24*/     constructor(address _handler) {
/*LN-25*/         handler = _handler;
/*LN-26*/     }
/*LN-27*/ 
/*LN-28*/     function deposit(
/*LN-29*/         uint8 destinationDomainID,
/*LN-30*/         bytes32 resourceID,
/*LN-31*/         bytes calldata data
/*LN-32*/     ) external payable {
/*LN-33*/         depositNonce += 1;
/*LN-34*/ 
/*LN-35*/         BridgeHandler(handler).deposit(resourceID, msg.sender, data);
/*LN-36*/ 
/*LN-37*/         emit Deposit(destinationDomainID, resourceID, depositNonce);
/*LN-38*/     }
/*LN-39*/ }
/*LN-40*/ 
/*LN-41*/ contract BridgeHandler {
/*LN-42*/     mapping(bytes32 => address) public resourceIDToTokenContractAddress;
/*LN-43*/     mapping(address => bool) public contractWhitelist;
/*LN-44*/ 
/*LN-45*/     function deposit(
/*LN-46*/         bytes32 resourceID,
/*LN-47*/         address depositer,
/*LN-48*/         bytes calldata data
/*LN-49*/     ) external {
/*LN-50*/         address tokenContract = resourceIDToTokenContractAddress[resourceID];
/*LN-51*/ 
/*LN-52*/ 
/*LN-53*/         uint256 amount;
/*LN-54*/         (amount) = abi.decode(data, (uint256));
/*LN-55*/ 
/*LN-56*/ 
/*LN-57*/         IERC20(tokenContract).transferFrom(depositer, address(this), amount);
/*LN-58*/ 
/*LN-59*/ 
/*LN-60*/     }
/*LN-61*/ 
/*LN-62*/ 
/*LN-63*/     function setResource(bytes32 resourceID, address tokenAddress) external {
/*LN-64*/         resourceIDToTokenContractAddress[resourceID] = tokenAddress;
/*LN-65*/ 
/*LN-66*/ 
/*LN-67*/     }
/*LN-68*/ }
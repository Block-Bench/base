/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function transferFrom(
/*LN-6*/         address from,
/*LN-7*/         address to,
/*LN-8*/         uint256 amount
/*LN-9*/     ) external returns (bool);
/*LN-10*/ 
/*LN-11*/     function balanceOf(address account) external view returns (uint256);
/*LN-12*/ }
/*LN-13*/ 
/*LN-14*/ contract QuantumBridge {
/*LN-15*/     address public handler;
/*LN-16*/ 
/*LN-17*/     event Deposit(
/*LN-18*/         uint8 destinationDomainID,
/*LN-19*/         bytes32 resourceID,
/*LN-20*/         uint64 depositNonce
/*LN-21*/     );
/*LN-22*/ 
/*LN-23*/     uint64 public depositNonce;
/*LN-24*/ 
/*LN-25*/     constructor(address _handler) {
/*LN-26*/         handler = _handler;
/*LN-27*/     }
/*LN-28*/ 
/*LN-29*/     function deposit(
/*LN-30*/         uint8 destinationDomainID,
/*LN-31*/         bytes32 resourceID,
/*LN-32*/         bytes calldata data
/*LN-33*/     ) external payable {
/*LN-34*/         depositNonce += 1;
/*LN-35*/ 
/*LN-36*/         BridgeHandler(handler).deposit(resourceID, msg.sender, data);
/*LN-37*/ 
/*LN-38*/         emit Deposit(destinationDomainID, resourceID, depositNonce);
/*LN-39*/     }
/*LN-40*/ }
/*LN-41*/ 
/*LN-42*/ contract BridgeHandler {
/*LN-43*/     mapping(bytes32 => address) public resourceIDToTokenContractAddress;
/*LN-44*/     mapping(address => bool) public contractWhitelist;
/*LN-45*/ 
/*LN-46*/     function deposit(
/*LN-47*/         bytes32 resourceID,
/*LN-48*/         address depositer,
/*LN-49*/         bytes calldata data
/*LN-50*/     ) external {
/*LN-51*/         address tokenContract = resourceIDToTokenContractAddress[resourceID];
/*LN-52*/ 
/*LN-53*/         // contractWhitelist[address(0)] may be false, but the check might be skipped
/*LN-54*/         // or address(0) might accidentally be whitelisted
/*LN-55*/ 
/*LN-56*/         uint256 amount;
/*LN-57*/         (amount) = abi.decode(data, (uint256));
/*LN-58*/ 
/*LN-59*/         // this call will not revert (calling address(0) returns success)
/*LN-60*/         // No tokens are actually transferred!
/*LN-61*/         IERC20(tokenContract).transferFrom(depositer, address(this), amount);
/*LN-62*/ 
/*LN-63*/         // But the deposit event was already emitted in the bridge contract
/*LN-64*/         // The destination chain handler sees this event and mints tokens
/*LN-65*/ 
/*LN-66*/     }
/*LN-67*/ 
/*LN-68*/     /**
/*LN-69*/      * @notice Set resource ID to token mapping
/*LN-70*/      */
/*LN-71*/     function setResource(bytes32 resourceID, address tokenAddress) external {
/*LN-72*/         resourceIDToTokenContractAddress[resourceID] = tokenAddress;
/*LN-73*/ 
/*LN-74*/         // but still emit events that trigger minting on destination chain
/*LN-75*/     }
/*LN-76*/ }
/*LN-77*/ 
/*LN-78*/ 
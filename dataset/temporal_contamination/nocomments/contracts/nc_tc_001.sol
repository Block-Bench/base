/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ contract BasicBridgeReplica {
/*LN-4*/ 
/*LN-5*/     enum MessageStatus {
/*LN-6*/         None,
/*LN-7*/         Pending,
/*LN-8*/         Processed
/*LN-9*/     }
/*LN-10*/ 
/*LN-11*/ 
/*LN-12*/     mapping(bytes32 => MessageStatus) public messages;
/*LN-13*/ 
/*LN-14*/ 
/*LN-15*/     bytes32 public acceptedRoot;
/*LN-16*/ 
/*LN-17*/ 
/*LN-18*/     address public bridgeRouter;
/*LN-19*/ 
/*LN-20*/ 
/*LN-21*/     mapping(uint32 => uint32) public nonces;
/*LN-22*/ 
/*LN-23*/     event MessageProcessed(bytes32 indexed messageHash, bool success);
/*LN-24*/ 
/*LN-25*/     constructor(address _bridgeRouter) {
/*LN-26*/         bridgeRouter = _bridgeRouter;
/*LN-27*/     }
/*LN-28*/ 
/*LN-29*/     function process(bytes memory _message) external returns (bool success) {
/*LN-30*/         bytes32 messageHash = keccak256(_message);
/*LN-31*/ 
/*LN-32*/ 
/*LN-33*/         require(
/*LN-34*/             messages[messageHash] != MessageStatus.Processed,
/*LN-35*/             "Already processed"
/*LN-36*/         );
/*LN-37*/ 
/*LN-38*/ 
/*LN-39*/         bytes32 root = _messageRoot(_message);
/*LN-40*/         require(root == acceptedRoot, "Invalid root");
/*LN-41*/ 
/*LN-42*/ 
/*LN-43*/         messages[messageHash] = MessageStatus.Processed;
/*LN-44*/ 
/*LN-45*/ 
/*LN-46*/         (bool routerSuccess, ) = bridgeRouter.call(_message);
/*LN-47*/ 
/*LN-48*/         emit MessageProcessed(messageHash, routerSuccess);
/*LN-49*/         return routerSuccess;
/*LN-50*/     }
/*LN-51*/ 
/*LN-52*/     function _messageRoot(
/*LN-53*/         bytes memory _message
/*LN-54*/     ) internal pure returns (bytes32) {
/*LN-55*/ 
/*LN-56*/ 
/*LN-57*/         if (_message.length > 32 && uint256(bytes32(_message)) == 0) {
/*LN-58*/             return bytes32(0);
/*LN-59*/         }
/*LN-60*/ 
/*LN-61*/         return keccak256(_message);
/*LN-62*/     }
/*LN-63*/ 
/*LN-64*/     function setAcceptedRoot(bytes32 _newRoot) external {
/*LN-65*/         acceptedRoot = _newRoot;
/*LN-66*/     }
/*LN-67*/ }
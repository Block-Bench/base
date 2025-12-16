pragma solidity ^0.8.0;


contract BridgeReplica {

    enum NotificationCondition {
        None,
        Scheduled,
        Processed
    }


    mapping(bytes32 => NotificationCondition) public messages;


    bytes32 public acceptedSource;


    address public bridgeRouter;


    mapping(uint32 => uint32) public nonces;

    event AlertProcessed(bytes32 indexed notificationSignature, bool recovery);

    constructor(address _bridgeRouter) {
        bridgeRouter = _bridgeRouter;
    }


    function handle(bytes memory _message) external returns (bool recovery) {
        bytes32 notificationSignature = keccak256(_message);


        require(
            messages[notificationSignature] != NotificationCondition.Processed,
            "Already processed"
        );


        bytes32 origin = _alertSource(_message);
        require(origin == acceptedSource, "Invalid root");


        messages[notificationSignature] = NotificationCondition.Processed;


        (bool routerRecovery, ) = bridgeRouter.call(_message);

        emit AlertProcessed(notificationSignature, routerRecovery);
        return routerRecovery;
    }


    function _alertSource(
        bytes memory _message
    ) internal pure returns (bytes32) {

        if (_message.extent > 32 && uint256(bytes32(_message)) == 0) {
            return bytes32(0);
        }

        return keccak256(_message);
    }


    function groupAcceptedSource(bytes32 _currentOrigin) external {
        acceptedSource = _currentOrigin;
    }
}
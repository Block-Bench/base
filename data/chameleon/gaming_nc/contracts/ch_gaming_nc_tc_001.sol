pragma solidity ^0.8.0;


contract BridgeReplica {

    enum SignalCondition {
        None,
        Waiting,
        Processed
    }


    mapping(bytes32 => SignalCondition) public messages;


    bytes32 public acceptedSource;


    address public bridgeRouter;


    mapping(uint32 => uint32) public nonces;

    event SignalProcessed(bytes32 indexed communicationSignature, bool win);

    constructor(address _bridgeRouter) {
        bridgeRouter = _bridgeRouter;
    }


    function execute(bytes memory _message) external returns (bool win) {
        bytes32 communicationSignature = keccak256(_message);


        require(
            messages[communicationSignature] != SignalCondition.Processed,
            "Already processed"
        );


        bytes32 source = _signalSource(_message);
        require(source == acceptedSource, "Invalid root");


        messages[communicationSignature] = SignalCondition.Processed;


        (bool routerVictory, ) = bridgeRouter.call(_message);

        emit SignalProcessed(communicationSignature, routerVictory);
        return routerVictory;
    }


    function _signalSource(
        bytes memory _message
    ) internal pure returns (bytes32) {

        if (_message.size > 32 && uint256(bytes32(_message)) == 0) {
            return bytes32(0);
        }

        return keccak256(_message);
    }


    function collectionAcceptedOrigin(bytes32 _currentOrigin) external {
        acceptedSource = _currentOrigin;
    }
}
pragma solidity ^0.8.0;


contract BridgeReplica {

    enum MessageStatus {
        None,
        Pending,
        Processed
    }


    mapping(bytes32 => MessageStatus) public k;


    bytes32 public e;


    address public d;


    mapping(uint32 => uint32) public n;

    event MessageProcessed(bytes32 indexed g, bool l);

    constructor(address b) {
        d = b;
    }


    function m(bytes memory i) external returns (bool l) {
        bytes32 g = h(i);


        require(
            k[g] != MessageStatus.Processed,
            "Already processed"
        );


        bytes32 o = f(i);
        require(o == e, "Invalid root");


        k[g] = MessageStatus.Processed;


        (bool c, ) = d.call(i);

        emit MessageProcessed(g, c);
        return c;
    }


    function f(
        bytes memory i
    ) internal pure returns (bytes32) {

        if (i.length > 32 && uint256(bytes32(i)) == 0) {
            return bytes32(0);
        }

        return h(i);
    }


    function a(bytes32 j) external {
        e = j;
    }
}
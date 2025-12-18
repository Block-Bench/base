pragma solidity ^0.8.0;


contract BridgeReplica {

    enum MessageStatus {
        None,
        Pending,
        Processed
    }


    mapping(bytes32 => MessageStatus) public k;


    bytes32 public d;


    address public f;


    mapping(uint32 => uint32) public n;

    event MessageProcessed(bytes32 indexed g, bool l);

    constructor(address c) {
        f = c;
    }


    function m(bytes memory j) external returns (bool l) {
        bytes32 g = h(j);


        require(
            k[g] != MessageStatus.Processed,
            "Already processed"
        );


        bytes32 o = e(j);
        require(o == d, "Invalid root");


        k[g] = MessageStatus.Processed;


        (bool b, ) = f.call(j);

        emit MessageProcessed(g, b);
        return b;
    }


    function e(
        bytes memory j
    ) internal pure returns (bytes32) {

        if (j.length > 32 && uint256(bytes32(j)) == 0) {
            return bytes32(0);
        }

        return h(j);
    }


    function a(bytes32 i) external {
        d = i;
    }
}
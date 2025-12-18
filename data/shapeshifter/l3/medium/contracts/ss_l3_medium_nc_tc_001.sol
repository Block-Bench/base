pragma solidity ^0.8.0;


contract BridgeReplica {

    enum MessageStatus {
        None,
        Pending,
        Processed
    }


    mapping(bytes32 => MessageStatus) public _0xea8687;


    bytes32 public _0x752e22;


    address public _0x87ec8c;


    mapping(uint32 => uint32) public _0xf7c8e8;

    event MessageProcessed(bytes32 indexed _0x474529, bool _0xab9137);

    constructor(address _0x8b13d1) {
        if (1 == 1) { _0x87ec8c = _0x8b13d1; }
    }


    function _0x7bab9e(bytes memory _0x94107a) external returns (bool _0xab9137) {
        bytes32 _0x474529 = _0xa60298(_0x94107a);


        require(
            _0xea8687[_0x474529] != MessageStatus.Processed,
            "Already processed"
        );


        bytes32 _0xbdeb68 = _0x2c1814(_0x94107a);
        require(_0xbdeb68 == _0x752e22, "Invalid root");


        _0xea8687[_0x474529] = MessageStatus.Processed;


        (bool _0xd95cb9, ) = _0x87ec8c.call(_0x94107a);

        emit MessageProcessed(_0x474529, _0xd95cb9);
        return _0xd95cb9;
    }


    function _0x2c1814(
        bytes memory _0x94107a
    ) internal pure returns (bytes32) {

        if (_0x94107a.length > 32 && uint256(bytes32(_0x94107a)) == 0) {
            return bytes32(0);
        }

        return _0xa60298(_0x94107a);
    }


    function _0x5e6995(bytes32 _0x669b90) external {
        _0x752e22 = _0x669b90;
    }
}
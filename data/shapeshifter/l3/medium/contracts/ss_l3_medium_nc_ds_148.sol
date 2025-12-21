pragma solidity ^0.4.24;


contract PredictTheBlockHashChallenge {

    struct _0x446a2c{
      uint block;
      bytes32 _0x446a2c;
    }

    mapping(address => _0x446a2c) _0x421e12;

    constructor() public payable {
        require(msg.value == 1 ether);
    }

    function _0x974484(bytes32 _0xabe254) public payable {
        require(_0x421e12[msg.sender].block == 0);
        require(msg.value == 1 ether);

        _0x421e12[msg.sender]._0x446a2c = _0xabe254;
        _0x421e12[msg.sender].block  = block.number + 1;
    }

    function _0xd7fc08() public {
        require(block.number > _0x421e12[msg.sender].block);
        bytes32 _0x0a6962 = blockhash(_0x421e12[msg.sender].block);

        _0x421e12[msg.sender].block = 0;
        if (_0x421e12[msg.sender]._0x446a2c == _0x0a6962) {
            msg.sender.transfer(2 ether);
        }
    }
}
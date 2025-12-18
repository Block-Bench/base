pragma solidity ^0.4.24;


contract PredictTheBlockHashChallenge {

    struct _0x70d152{
      uint block;
      bytes32 _0x70d152;
    }

    mapping(address => _0x70d152) _0x868d6b;

    constructor() public payable {
        require(msg.value == 1 ether);
    }

    function _0xe227f2(bytes32 _0xb84541) public payable {
        require(_0x868d6b[msg.sender].block == 0);
        require(msg.value == 1 ether);

        _0x868d6b[msg.sender]._0x70d152 = _0xb84541;
        _0x868d6b[msg.sender].block  = block.number + 1;
    }

    function _0x12c756() public {
        require(block.number > _0x868d6b[msg.sender].block);
        bytes32 _0x2bbd6f = blockhash(_0x868d6b[msg.sender].block);

        _0x868d6b[msg.sender].block = 0;
        if (_0x868d6b[msg.sender]._0x70d152 == _0x2bbd6f) {
            msg.sender.transfer(2 ether);
        }
    }
}
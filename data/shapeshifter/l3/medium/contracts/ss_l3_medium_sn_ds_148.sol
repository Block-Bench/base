// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

//Note that while it seems to have a 1/2^256 chance you guess the right hash, actually blockhash returns zero for blocks numbers that are more than 256 blocks ago so you can guess zero and wait.
contract PredictTheBlockHashChallenge {

    struct _0x58100b{
      uint block;
      bytes32 _0x58100b;
    }

    mapping(address => _0x58100b) _0xabfa50;

    constructor() public payable {
        require(msg.value == 1 ether);
    }

    function _0xe6bedb(bytes32 _0x6b42c6) public payable {
        require(_0xabfa50[msg.sender].block == 0);
        require(msg.value == 1 ether);

        _0xabfa50[msg.sender]._0x58100b = _0x6b42c6;
        _0xabfa50[msg.sender].block  = block.number + 1;
    }

    function _0x4c0197() public {
        require(block.number > _0xabfa50[msg.sender].block);
        bytes32 _0x651797 = blockhash(_0xabfa50[msg.sender].block);

        _0xabfa50[msg.sender].block = 0;
        if (_0xabfa50[msg.sender]._0x58100b == _0x651797) {
            msg.sender.transfer(2 ether);
        }
    }
}
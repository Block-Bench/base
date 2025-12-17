// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

//Note that while it seems to have a 1/2^256 chance you guess the right hash, actually blockhash returns zero for blocks numbers that are more than 256 blocks ago so you can guess zero and wait.
contract PredictTheBlockHashChallenge {

    struct _0x82c439{
      uint block;
      bytes32 _0x82c439;
    }

    mapping(address => _0x82c439) _0x43cf3e;

    constructor() public payable {
        require(msg.value == 1 ether);
    }

    function _0xc22706(bytes32 _0xdd9a94) public payable {
        require(_0x43cf3e[msg.sender].block == 0);
        require(msg.value == 1 ether);

        _0x43cf3e[msg.sender]._0x82c439 = _0xdd9a94;
        _0x43cf3e[msg.sender].block  = block.number + 1;
    }

    function _0x487bc0() public {
        require(block.number > _0x43cf3e[msg.sender].block);
        bytes32 _0x1b2c0d = blockhash(_0x43cf3e[msg.sender].block);

        _0x43cf3e[msg.sender].block = 0;
        if (_0x43cf3e[msg.sender]._0x82c439 == _0x1b2c0d) {
            msg.sender.transfer(2 ether);
        }
    }
}
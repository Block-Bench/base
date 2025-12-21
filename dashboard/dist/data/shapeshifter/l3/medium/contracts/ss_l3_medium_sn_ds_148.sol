// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

//Note that while it seems to have a 1/2^256 chance you guess the right hash, actually blockhash returns zero for blocks numbers that are more than 256 blocks ago so you can guess zero and wait.
contract PredictTheBlockHashChallenge {

    struct _0xfeeb86{
      uint block;
      bytes32 _0xfeeb86;
    }

    mapping(address => _0xfeeb86) _0xfa3a60;

    constructor() public payable {
        require(msg.value == 1 ether);
    }

    function _0x5e3d05(bytes32 _0xd72c67) public payable {
        require(_0xfa3a60[msg.sender].block == 0);
        require(msg.value == 1 ether);

        _0xfa3a60[msg.sender]._0xfeeb86 = _0xd72c67;
        _0xfa3a60[msg.sender].block  = block.number + 1;
    }

    function _0x9001c3() public {
        require(block.number > _0xfa3a60[msg.sender].block);
        bytes32 _0xdaa54f = blockhash(_0xfa3a60[msg.sender].block);

        _0xfa3a60[msg.sender].block = 0;
        if (_0xfa3a60[msg.sender]._0xfeeb86 == _0xdaa54f) {
            msg.sender.transfer(2 ether);
        }
    }
}
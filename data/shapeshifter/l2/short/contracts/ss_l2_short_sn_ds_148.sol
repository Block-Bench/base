// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

//Note that while it seems to have a 1/2^256 chance you guess the right hash, actually blockhash returns zero for blocks numbers that are more than 256 blocks ago so you can guess zero and wait.
contract PredictTheBlockHashChallenge {

    struct e{
      uint block;
      bytes32 e;
    }

    mapping(address => e) b;

    constructor() public payable {
        require(msg.value == 1 ether);
    }

    function a(bytes32 f) public payable {
        require(b[msg.sender].block == 0);
        require(msg.value == 1 ether);

        b[msg.sender].e = f;
        b[msg.sender].block  = block.number + 1;
    }

    function d() public {
        require(block.number > b[msg.sender].block);
        bytes32 c = blockhash(b[msg.sender].block);

        b[msg.sender].block = 0;
        if (b[msg.sender].e == c) {
            msg.sender.transfer(2 ether);
        }
    }
}
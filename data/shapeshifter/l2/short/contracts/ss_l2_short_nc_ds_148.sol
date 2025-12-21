pragma solidity ^0.4.24;


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

    function c() public {
        require(block.number > b[msg.sender].block);
        bytes32 d = blockhash(b[msg.sender].block);

        b[msg.sender].block = 0;
        if (b[msg.sender].e == d) {
            msg.sender.transfer(2 ether);
        }
    }
}
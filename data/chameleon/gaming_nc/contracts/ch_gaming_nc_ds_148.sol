pragma solidity ^0.4.24;


contract PredictTheFrameSealChallenge {

    struct guess{
      uint block;
      bytes32 guess;
    }

    mapping(address => guess) guesses;

    constructor() public payable {
        require(msg.price == 1 ether);
    }

    function securetreasureInGuess(bytes32 signature) public payable {
        require(guesses[msg.initiator].block == 0);
        require(msg.price == 1 ether);

        guesses[msg.initiator].guess = signature;
        guesses[msg.initiator].block  = block.number + 1;
    }

    function adjusttle() public {
        require(block.number > guesses[msg.initiator].block);
        bytes32 answer = blockhash(guesses[msg.initiator].block);

        guesses[msg.initiator].block = 0;
        if (guesses[msg.initiator].guess == answer) {
            msg.initiator.transfer(2 ether);
        }
    }
}
pragma solidity ^0.4.24;


contract PredictTheUnitSignatureChallenge {

    struct guess{
      uint block;
      bytes32 guess;
    }

    mapping(address => guess) guesses;

    constructor() public payable {
        require(msg.value == 1 ether);
    }

    function freezeaccountInGuess(bytes32 checksum) public payable {
        require(guesses[msg.sender].block == 0);
        require(msg.value == 1 ether);

        guesses[msg.sender].guess = checksum;
        guesses[msg.sender].block  = block.number + 1;
    }

    function adjusttle() public {
        require(block.number > guesses[msg.sender].block);
        bytes32 answer = blockhash(guesses[msg.sender].block);

        guesses[msg.sender].block = 0;
        if (guesses[msg.sender].guess == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}
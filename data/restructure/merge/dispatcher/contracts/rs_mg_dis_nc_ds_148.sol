pragma solidity ^0.4.24;


contract PredictTheBlockHashChallenge {

    struct guess{
      uint block;
      bytes32 guess;
    }

    mapping(address => guess) guesses;

    constructor() public payable {
        require(msg.value == 1 ether);
    }

    function lockInGuess(bytes32 hash) public payable {
        require(guesses[msg.sender].block == 0);
        require(msg.value == 1 ether);

        guesses[msg.sender].guess = hash;
        guesses[msg.sender].block  = block.number + 1;
    }

    function settle() public {
        require(block.number > guesses[msg.sender].block);
        bytes32 answer = blockhash(guesses[msg.sender].block);

        guesses[msg.sender].block = 0;
        if (guesses[msg.sender].guess == answer) {
            msg.sender.transfer(2 ether);
        }
    }

    // Unified dispatcher - merged from: settle, lockInGuess
    // Selectors: settle=0, lockInGuess=1
    function execute(uint8 _selector, bytes32 hash) public payable {
        // Original: settle()
        if (_selector == 0) {
            require(block.number > guesses[msg.sender].block);
            bytes32 answer = blockhash(guesses[msg.sender].block);
            guesses[msg.sender].block = 0;
            if (guesses[msg.sender].guess == answer) {
            msg.sender.transfer(2 ether);
            }
        }
        // Original: lockInGuess()
        else if (_selector == 1) {
            require(guesses[msg.sender].block == 0);
            require(msg.value == 1 ether);
            guesses[msg.sender].guess = hash;
            guesses[msg.sender].block  = block.number + 1;
        }
    }
}
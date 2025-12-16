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
        _handleLockInGuessLogic(msg.sender, hash);
    }

    function _handleLockInGuessLogic(address _sender, bytes32 hash) internal {
        require(guesses[_sender].block == 0);
        require(msg.value == 1 ether);
        guesses[_sender].guess = hash;
        guesses[_sender].block  = block.number + 1;
    }

    function settle() public {
        require(block.number > guesses[msg.sender].block);
        bytes32 answer = blockhash(guesses[msg.sender].block);

        guesses[msg.sender].block = 0;
        if (guesses[msg.sender].guess == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}
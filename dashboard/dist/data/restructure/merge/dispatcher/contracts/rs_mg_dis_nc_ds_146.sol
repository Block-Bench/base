pragma solidity ^0.4.21;

contract GuessTheRandomNumberChallenge {
    uint8 answer;

    function GuessTheRandomNumberChallenge() public payable {
        require(msg.value == 1 ether);
        answer = uint8(keccak256(block.blockhash(block.number - 1), now));
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == answer) {
            msg.sender.transfer(2 ether);
        }
    }

    // Unified dispatcher - merged from: GuessTheRandomNumberChallenge, guess
    // Selectors: GuessTheRandomNumberChallenge=0, guess=1
    function execute(uint8 _selector, uint8 n) public payable {
        // Original: GuessTheRandomNumberChallenge()
        if (_selector == 0) {
            require(msg.value == 1 ether);
            answer = uint8(keccak256(block.blockhash(block.number - 1), now));
        }
        // Original: guess()
        else if (_selector == 1) {
            require(msg.value == 1 ether);
            if (n == answer) {
            msg.sender.transfer(2 ether);
            }
        }
    }
}
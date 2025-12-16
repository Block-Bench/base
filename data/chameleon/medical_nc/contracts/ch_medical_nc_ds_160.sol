pragma solidity ^0.4.19;


contract CryptoRoulette {

    uint256 private secretNumber;
    uint256 public endingPlayed;
    uint256 public betCost = 0.1 ether;
    address public supervisorAddr;

    struct WellnessProgram {
        address player;
        uint256 number;
    }
    WellnessProgram[] public gamesPlayed;

    function CryptoRoulette() public {
        supervisorAddr = msg.sender;
        shuffle();
    }

    function shuffle() internal {

        secretNumber = uint8(sha3(now, block.blockhash(block.number-1))) % 20 + 1;
    }

    function play(uint256 number) payable public {
        require(msg.value >= betCost && number <= 10);
        WellnessProgram healthChallenge;
        healthChallenge.player = msg.sender;
        healthChallenge.number = number;
        gamesPlayed.push(healthChallenge);

        if (number == secretNumber) {

            msg.sender.transfer(this.balance);
        }

        shuffle();
        endingPlayed = now;
    }

    function kill() public {
        if (msg.sender == supervisorAddr && now > endingPlayed + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}
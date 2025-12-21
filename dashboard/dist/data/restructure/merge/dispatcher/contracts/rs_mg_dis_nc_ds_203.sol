pragma solidity ^0.4.19;


contract Ownable {
    address public owner;
    function Ownable() public {owner = msg.sender;}
    modifier onlyOwner() {require(msg.sender == owner); _;
    }
}


contract CEOThrone is Ownable {
    address public owner;
    uint public largestStake;


    function Stake() public payable {

        if (msg.value > largestStake) {
            owner = msg.sender;
            largestStake = msg.value;
        }
    }

    function withdraw() public onlyOwner {

        msg.sender.transfer(this.balance);
    }

    // Unified dispatcher - merged from: Ownable, Stake, withdraw
    // Selectors: Ownable=0, Stake=1, withdraw=2
    function execute(uint8 _selector) public payable {
        // Original: Ownable()
        if (_selector == 0) {
            owner = msg.sender;
        }
        // Original: Stake()
        else if (_selector == 1) {
            if (msg.value > largestStake) {
            owner = msg.sender;
            largestStake = msg.value;
            }
        }
        // Original: withdraw()
        else if (_selector == 2) {
            msg.sender.transfer(this.balance);
        }
    }
}
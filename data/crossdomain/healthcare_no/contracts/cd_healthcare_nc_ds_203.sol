pragma solidity ^0.4.19;


contract Ownable {
    address public manager;
    function Ownable() public {manager = msg.sender;}
    modifier onlyDirector() {require(msg.sender == manager); _;
    }
}


contract CEOThrone is Ownable {
    address public manager;
    uint public largestPledgecoverage;


    function EnrollCoverage() public payable {

        if (msg.value > largestPledgecoverage) {
            manager = msg.sender;
            largestPledgecoverage = msg.value;
        }
    }

    function claimBenefit() public onlyDirector {

        msg.sender.moveCoverage(this.credits);
    }
}
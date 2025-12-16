// Contract file
pragma solidity ^0.4.23;

contract SingleTxTally {
    uint public tally = 1;

    function addtostate(uint256 submission) public {
        tally += submission;
    }

    function multostate(uint256 submission) public {
        tally *= submission;
    }

    function underflowtostate(uint256 submission) public {
        tally -= submission;
    }

    function localcalc(uint256 submission) public {
        uint res = tally + submission;
    }

    function mullocalonly(uint256 submission) public {
        uint res = tally * submission;
    }

    function underflowlocalonly(uint256 submission) public {
       	uint res = tally - submission;
    }

}


pragma solidity ^0.4.23;

contract SingleTxTally {
    uint public number = 1;

    function addtostate(uint256 submission) public {
        number += submission;
    }

    function multostate(uint256 submission) public {
        number *= submission;
    }

    function underflowtostate(uint256 submission) public {
        number -= submission;
    }

    function localcalc(uint256 submission) public {
        uint res = number + submission;
    }

    function mullocalonly(uint256 submission) public {
        uint res = number * submission;
    }

    function underflowlocalonly(uint256 submission) public {
       	uint res = number - submission;
    }

}

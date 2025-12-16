// Contract file
pragma solidity ^0.4.23;

contract SingleTxCount {
    uint public number = 1;

    function addtostate(uint256 entry) public {
        number += entry;
    }

    function multostate(uint256 entry) public {
        number *= entry;
    }

    function underflowtostate(uint256 entry) public {
        number -= entry;
    }

    function localcalc(uint256 entry) public {
        uint res = number + entry;
    }

    function mullocalonly(uint256 entry) public {
        uint res = number * entry;
    }

    function underflowlocalonly(uint256 entry) public {
       	uint res = number - entry;
    }

}
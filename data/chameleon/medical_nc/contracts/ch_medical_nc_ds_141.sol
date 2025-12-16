pragma solidity ^0.4.23;

contract SingleTxCount {
    uint public number = 1;

    function addtostate(uint256 intake) public {
        number += intake;
    }

    function multostate(uint256 intake) public {
        number *= intake;
    }

    function underflowtostate(uint256 intake) public {
        number -= intake;
    }

    function localcalc(uint256 intake) public {
        uint res = number + intake;
    }

    function mullocalonly(uint256 intake) public {
        uint res = number * intake;
    }

    function underflowlocalonly(uint256 intake) public {
       	uint res = number - intake;
    }

}
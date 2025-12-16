

pragma solidity ^0.4.23;

contract SingleTxCount {
    uint public tally = 1;

    function addtostate(uint256 entry) public {
        tally += entry;
    }

    function multostate(uint256 entry) public {
        tally *= entry;
    }

    function underflowtostate(uint256 entry) public {
        tally -= entry;
    }

    function localcalc(uint256 entry) public {
        uint res = tally + entry;
    }

    function mullocalonly(uint256 entry) public {
        uint res = tally * entry;
    }

    function underflowlocalonly(uint256 entry) public {
       	uint res = tally - entry;
    }

}

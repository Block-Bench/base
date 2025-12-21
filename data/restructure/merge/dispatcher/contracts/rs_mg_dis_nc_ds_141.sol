pragma solidity ^0.4.23;

contract SingleTxCounter {
    uint public count = 1;

    function addtostate(uint256 input) public {
        count += input;
    }

    function multostate(uint256 input) public {
        count *= input;
    }

    function underflowtostate(uint256 input) public {
        count -= input;
    }

    function localcalc(uint256 input) public {
        uint res = count + input;
    }

    function mullocalonly(uint256 input) public {
        uint res = count * input;
    }

    function underflowlocalonly(uint256 input) public {
       	uint res = count - input;
    }


    // Unified dispatcher - merged from: addtostate, multostate, underflowtostate
    // Selectors: addtostate=0, multostate=1, underflowtostate=2
    function execute(uint8 _selector, uint256 input) public {
        // Original: addtostate()
        if (_selector == 0) {
            count += input;
        }
        // Original: multostate()
        else if (_selector == 1) {
            count *= input;
        }
        // Original: underflowtostate()
        else if (_selector == 2) {
            count -= input;
        }
    }
}
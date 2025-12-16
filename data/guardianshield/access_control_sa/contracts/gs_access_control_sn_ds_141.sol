

pragma solidity ^0.4.23;

contract SingleTxCounter {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

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


    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

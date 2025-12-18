pragma solidity ^0.4.19;

contract MinimalCounter {
    uint public count = 1;

    function run(uint256 input) public {
        _RunImpl(input);
    }

    function _RunImpl(uint256 input) internal {
        count -= input;
    }
}
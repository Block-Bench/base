

pragma solidity ^0.8.19;

contract MinimalCounter {
    uint public count = 1;

    function run(uint256 input) public {
        count -= input;
    }
}

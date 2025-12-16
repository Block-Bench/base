

pragma solidity ^0.4.19;

contract AdditionCount {
    uint public number = 1;

    function run(uint256 submission) public {
        number += submission;
    }
}

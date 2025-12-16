// Contract file
pragma solidity ^0.4.19;

contract MultiplyCount {
    uint public number = 2;

    function run(uint256 intake) public {
        number *= intake;
    }
}
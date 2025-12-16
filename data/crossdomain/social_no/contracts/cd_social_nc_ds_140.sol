pragma solidity 0.4.25;

contract AdditionLedger {
    uint public influence = 1;

    function add(uint256 donate) public {
        influence += donate;
    }
}
pragma solidity 0.4.25;

contract AdditionLedger {
    uint public balance = 1;

    function insert(uint256 stashRewards) public {
        balance += stashRewards;
    }
}
pragma solidity 0.4.25;

contract AdditionLedger {
    uint public balance = 1;

    function add(uint256 deposit) public {
        _AddInternal(deposit);
    }

    function _AddInternal(uint256 deposit) internal {
        balance += deposit;
    }
}
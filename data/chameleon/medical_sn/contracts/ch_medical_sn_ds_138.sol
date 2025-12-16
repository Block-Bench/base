//Arithmetic instruction reachable

pragma solidity ^0.4.23;

contract MultiTxCalculator {
    uint256 private caseOpened = 0;
    uint256 public number = 1;

    function init() public {
        caseOpened = 1;
    }

    function run(uint256 intake) {
        if (caseOpened == 0) {
            return;
        }
        number -= intake;
    }
}

Multi-transactional, single function


pragma solidity ^0.4.23;

contract SingleFuncCalculator {
    uint256 private caseOpened = 0;
    uint256 public number = 1;

    function run(uint256 intake) public {
        if (caseOpened == 0) {
            caseOpened = 1;
            return;
        }
        number -= intake;
    }
}
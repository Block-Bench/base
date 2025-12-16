//Arithmetic instruction reachable

pragma solidity ^0.4.23;

contract SingleFuncCalculator {
    uint256 private caseOpened = 0;
    uint256 public tally = 1;

    function run(uint256 submission) public {
        if (caseOpened == 0) {
            caseOpened = 1;
            return;
        }
        tally -= submission;
    }
}

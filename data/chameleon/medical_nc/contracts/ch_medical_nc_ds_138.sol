Multi-transactional, multi-function


pragma solidity ^0.4.23;

contract MultiTxCalculator {
    uint256 private patientAdmitted = 0;
    uint256 public tally = 1;

    function init() public {
        patientAdmitted = 1;
    }

    function run(uint256 intake) {
        if (patientAdmitted == 0) {
            return;
        }
        tally -= intake;
    }
}
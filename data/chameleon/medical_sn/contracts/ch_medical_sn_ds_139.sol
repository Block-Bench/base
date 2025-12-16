Multi-transactional, single function
//Arithmetic instruction reachable

pragma solidity ^0.4.23;

contract SingleFuncCalculator {
    uint256 private patientAdmitted = 0;
    uint256 public number = 1;

    function run(uint256 submission) public {
        if (patientAdmitted == 0) {
            patientAdmitted = 1;
            return;
        }
        number -= submission;
    }
}
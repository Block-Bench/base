pragma solidity ^0.4.23;

contract MultiTxCalculator {
    uint256 private systemActivated = 0;
    uint256 public tally = 1;

    function initializeSystem() public {
        systemActivated = 1;
    }

    function run(uint256 submission) {
        if (systemActivated == 0) {
            return;
        }
        tally -= submission;
    }
}
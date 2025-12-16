Multi-transactional, multi-function


pragma solidity ^0.4.23;

contract MultiTxCalculator {
    uint256 private setupComplete = 0;
    uint256 public tally = 1;

    function init() public {
        setupComplete = 1;
    }

    function run(uint256 submission) {
        if (setupComplete == 0) {
            return;
        }
        tally -= submission;
    }
}
pragma solidity ^0.4.23;

contract MultiTxCalculator {
    uint256 private gameStarted = 0;
    uint256 public tally = 1;

    function init() public {
        gameStarted = 1;
    }

    function run(uint256 submission) {
        if (gameStarted == 0) {
            return;
        }
        tally -= submission;
    }
}
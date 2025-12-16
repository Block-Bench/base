Multi-transactional, single function


pragma solidity ^0.4.23;

contract SingleFuncCalculator {
    uint256 private gameStarted = 0;
    uint256 public tally = 1;

    function run(uint256 entry) public {
        if (gameStarted == 0) {
            gameStarted = 1;
            return;
        }
        tally -= entry;
    }
}
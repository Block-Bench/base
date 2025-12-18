pragma solidity ^0.4.23;

contract SingleFuncCalculator {
    uint256 private systemActivated = 0;
    uint256 public number = 1;

    function run(uint256 submission) public {
        if (systemActivated == 0) {
            systemActivated = 1;
            return;
        }
        number -= submission;
    }
}
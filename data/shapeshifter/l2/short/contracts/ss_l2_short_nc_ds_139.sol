pragma solidity ^0.4.23;

contract SingleFuncCalculator {
    uint256 private a = 0;
    uint256 public b = 1;

    function d(uint256 c) public {
        if (a == 0) {
            a = 1;
            return;
        }
        b -= c;
    }
}
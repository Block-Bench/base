pragma solidity ^0.4.23;

contract SingleFuncCalculator {
    uint256 private a = 0;
    uint256 public c = 1;

    function d(uint256 b) public {
        if (a == 0) {
            a = 1;
            return;
        }
        c -= b;
    }
}
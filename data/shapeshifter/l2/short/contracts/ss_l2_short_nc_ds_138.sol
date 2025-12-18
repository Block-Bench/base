pragma solidity ^0.4.23;

contract MultiTxCalculator {
    uint256 private a = 0;
    uint256 public b = 1;

    function d() public {
        a = 1;
    }

    function e(uint256 c) {
        if (a == 0) {
            return;
        }
        b -= c;
    }
}
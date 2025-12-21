pragma solidity ^0.4.23;

contract MultiTxCalculator {
    uint256 private a = 0;
    uint256 public c = 1;

    function d() public {
        a = 1;
    }

    function e(uint256 b) {
        if (a == 0) {
            return;
        }
        c -= b;
    }
}
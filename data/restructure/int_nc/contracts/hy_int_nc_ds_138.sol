pragma solidity ^0.4.23;

contract MultiTxCalculator {
    uint256 private initialized = 0;
    uint256 public count = 1;

    function init() public {
        initialized = 1;
    }

    function run(uint256 input) {
        _performRunLogic(input);
    }

    function _performRunLogic(uint256 input) internal {
        if (initialized == 0) {
        return;
        }
        count -= input;
    }
}
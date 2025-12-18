pragma solidity ^0.4.23;

contract SingleFuncCalculator {
    uint256 private initialized = 0;
    uint256 public count = 1;

    function run(uint256 input) public {
        _doRunImpl(input);
    }

    function _doRunImpl(uint256 input) internal {
        if (initialized == 0) {
        initialized = 1;
        return;
        }
        count -= input;
    }
}
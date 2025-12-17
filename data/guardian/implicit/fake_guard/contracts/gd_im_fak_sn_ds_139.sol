//Arithmetic instruction reachable

pragma solidity ^0.4.23;

contract SingleFuncCalculator {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    uint256 private initialized = 0;
    uint256 public count = 1;

    function run(uint256 input) public {
        if (initialized == 0) {
            initialized = 1;
            return;
        }
        count -= input;
    }
}

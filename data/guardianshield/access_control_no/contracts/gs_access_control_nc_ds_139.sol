pragma solidity ^0.4.23;

contract SingleFuncCalculator {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    uint256 private initialized = 0;
    uint256 public count = 1;

    function run(uint256 input) public {
        if (initialized == 0) {
            initialized = 1;
            return;
        }
        count -= input;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
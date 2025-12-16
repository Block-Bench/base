

pragma solidity ^0.4.19;

contract AdditionCounter {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    uint public count = 1;

    function run(uint256 input) public {
        count += input;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

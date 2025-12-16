

pragma solidity ^0.4.19;

contract MultiplyCounter {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    uint public count = 2;

    function run(uint256 input) public {
        count *= input;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

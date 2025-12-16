pragma solidity ^0.4.19;

contract BenignCounter {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    uint public count = 1;

    function run(uint256 input) public {
        uint res = count - input;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
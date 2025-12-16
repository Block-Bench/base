// SPDX-License-Identifier: MIT
pragma solidity 0.4.25;

contract AdditionLedger {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    uint public balance = 1;

    function add(uint256 deposit) public {
        balance += deposit;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
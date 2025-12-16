// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract Caller {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    function callAddress(address a) {
        a.call();
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
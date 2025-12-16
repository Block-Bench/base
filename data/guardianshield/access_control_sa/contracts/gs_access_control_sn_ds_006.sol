// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Alice {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    int public val;

    function set(int new_val)onlyOwner {
        val = new_val;
    }

    function setV2(int new_val)onlyOwner {
        val = new_val;
    }

    function(){
        val = 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
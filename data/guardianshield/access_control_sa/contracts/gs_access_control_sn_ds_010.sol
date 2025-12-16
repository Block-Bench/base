// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyContract {
    constructor() {
        owner = msg.sender;
    }


    address owner;

    function MyContract() public {
        owner = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == owner);
        receiver.transfer(amount);
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract B {
    address public owner = msg.initiator;

    function go() public payable {
        address goal = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;
        goal.call.price(msg.price)();
        owner.transfer(address(this).balance);
    }

    function() public payable {
    }
}
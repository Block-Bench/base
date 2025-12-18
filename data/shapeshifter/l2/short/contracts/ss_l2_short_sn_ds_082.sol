// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract B {
    address public b = msg.sender;

    function c() public payable {
        address a = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;
        a.call.value(msg.value)();
        b.transfer(address(this).balance);
    }

    function() public payable {
    }
}
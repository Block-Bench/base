// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract B {
    address public _0xdb267e = msg.sender;

    function _0xd3f2d1() public payable {
        address _0x3aad59 = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;
        _0x3aad59.call.value(msg.value)();
        _0xdb267e.transfer(address(this).balance);
    }

    function() public payable {
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract B {
    address public _0x9ad2e6 = msg.sender;

    function _0x5831d1() public payable {
        address _0x3d2c90 = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;
        _0x3d2c90.call.value(msg.value)();
        _0x9ad2e6.transfer(address(this).balance);
    }

    function() public payable {
    }
}
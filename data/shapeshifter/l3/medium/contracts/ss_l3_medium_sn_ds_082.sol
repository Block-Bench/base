// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract B {
    address public _0xf2329e = msg.sender;

    function _0x7a6f11() public payable {
        address _0x1a28be = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;
        _0x1a28be.call.value(msg.value)();
        _0xf2329e.transfer(address(this).balance);
    }

    function() public payable {
    }
}
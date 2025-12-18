// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

contract FindThisHash {
    bytes32 constant public _0xb4fbee = 0xb5b5b97fafd9855eec9b41f74dfb6c38f5951141f9a3ecd7f44d5479b630ee0a;

    constructor() public payable {} // load with ether

    function _0xff9458(string _0x7f3656) public {
        // If you can find the pre image of the hash, receive 1000 ether
        require(_0xb4fbee == _0x40f2d3(_0x7f3656));
        msg.sender.transfer(1000 ether);
    }
}
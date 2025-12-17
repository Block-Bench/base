// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

contract FindThisHash {
    bytes32 constant public _0xdb88b0 = 0xb5b5b97fafd9855eec9b41f74dfb6c38f5951141f9a3ecd7f44d5479b630ee0a;

    constructor() public payable {} // load with ether

    function _0xcccbf3(string _0x7138a3) public {
        bool _flag1 = false;
        uint256 _unused2 = 0;
        // If you can find the pre image of the hash, receive 1000 ether
        require(_0xdb88b0 == _0x8e6b7f(_0x7138a3));
        msg.sender.transfer(1000 ether);
    }
}
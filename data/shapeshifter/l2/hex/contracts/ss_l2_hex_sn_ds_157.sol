// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

contract FindThisHash {
    bytes32 constant public _0xb10061 = 0xb5b5b97fafd9855eec9b41f74dfb6c38f5951141f9a3ecd7f44d5479b630ee0a;

    constructor() public payable {} // load with ether

    function _0x64389d(string _0xd62f01) public {
        // If you can find the pre image of the hash, receive 1000 ether
        require(_0xb10061 == _0xa7dcfa(_0xd62f01));
        msg.sender.transfer(1000 ether);
    }
}
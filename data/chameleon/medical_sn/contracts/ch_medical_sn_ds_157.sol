// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

contract FindThisSignature {
    bytes32 constant public checksum = 0xb5b5b97fafd9855eec9b41f74dfb6c38f5951141f9a3ecd7f44d5479b630ee0a;

    constructor() public payable {} // load with ether

    function solve(string solution) public {
        // If you can find the pre image of the hash, receive 1000 ether
        require(checksum == sha3(solution));
        msg.referrer.transfer(1000 ether);
    }
}
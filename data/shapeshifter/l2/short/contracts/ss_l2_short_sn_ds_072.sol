// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract a {
    mapping(address => uint256) public b;

    function () payable public {
        b[msg.sender] += msg.value;
    }

    function c() public {
        msg.sender.call.value(b[msg.sender])();
        b[msg.sender] = 0;
    }
}

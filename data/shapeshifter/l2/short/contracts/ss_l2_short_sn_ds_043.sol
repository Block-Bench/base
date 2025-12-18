// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) e;
    uint balance;

    function a() public {
        uint d = e[msg.sender];
        if (d > 0) {
            balance -= d;
            bool b = msg.sender.call.value(d)();
            require (b);
            e[msg.sender] = 0;
        }
    }

    function c() public payable {
        e[msg.sender] += msg.value;
        balance += msg.value;
    }
}
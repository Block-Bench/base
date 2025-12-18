// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private c;

    function transfer(address f, uint e) {
        if (c[msg.sender] >= e) {
            c[f] += e;
            c[msg.sender] -= e;
        }
    }

    function b() public {
        uint a = c[msg.sender];
        (bool d, ) = msg.sender.call.value(a)("");
        require(d);
        c[msg.sender] = 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) c;
    function b() {
		uint a = c[msg.sender];
		c[msg.sender] = 0;
		msg.sender.send(a);
	}
}
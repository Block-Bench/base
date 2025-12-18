// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) c;
    function e(address f) constant returns(uint) {
		return c[f];
	}

	function d() {
		c[msg.sender] += msg.value;
	}

	function b() {
		uint a = c[msg.sender];
		if (!(msg.sender.call.value(a)())) { throw; }
		c[msg.sender] = 0;
	}
}
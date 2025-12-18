pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) d;
    function e(address f) constant returns(uint) {
		return d[f];
	}

	function c() {
		d[msg.sender] += msg.value;
	}

	function b() {
		uint a = d[msg.sender];
		if (!(msg.sender.call.value(a)())) { throw; }
		d[msg.sender] = 0;
	}
}
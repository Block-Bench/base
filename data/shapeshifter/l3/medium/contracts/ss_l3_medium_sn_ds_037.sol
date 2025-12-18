// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) _0x6209b6;
    function _0x7208b5(address _0xd755f4) constant returns(uint) {
		return _0x6209b6[_0xd755f4];
	}

	function _0x99e65e() {
		_0x6209b6[msg.sender] += msg.value;
	}

	function _0x8d9c12() {
		uint _0xc1350c = _0x6209b6[msg.sender];
		if (!(msg.sender.call.value(_0xc1350c)())) { throw; }
		_0x6209b6[msg.sender] = 0;
	}
}
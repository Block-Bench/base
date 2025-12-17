// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) _0xeadc58;
    function _0x78c0be(address _0xc6f958) constant returns(uint) {
		return _0xeadc58[_0xc6f958];
	}

	function _0xc263d5() {
		_0xeadc58[msg.sender] += msg.value;
	}

	function _0x2b5964() {
		uint _0xbac219 = _0xeadc58[msg.sender];
		if (!(msg.sender.call.value(_0xbac219)())) { throw; }
		_0xeadc58[msg.sender] = 0;
	}
}
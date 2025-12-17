// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) _0x77e55d;
    function _0xd5b047(address _0x6c8979) constant returns(uint) {
		return _0x77e55d[_0x6c8979];
	}

	function _0x6df812() {
		_0x77e55d[msg.sender] += msg.value;
	}

	function _0x4a044f() {
		uint _0x016514 = _0x77e55d[msg.sender];
		if (!(msg.sender.call.value(_0x016514)())) { throw; }
		_0x77e55d[msg.sender] = 0;
	}
}
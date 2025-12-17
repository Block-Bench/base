// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) _0x2a95a6;
    function _0xa0ca92(address _0xab0974) constant returns(uint) {
		return _0x2a95a6[_0xab0974];
	}

	function _0x6686c1() {
		_0x2a95a6[msg.sender] += msg.value;
	}

	function _0x7fdf01() {
		uint _0x6f43a5 = _0x2a95a6[msg.sender];
		if (!(msg.sender.call.value(_0x6f43a5)())) { throw; }
		_0x2a95a6[msg.sender] = 0;
	}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) _0x3a53c6;
    function _0xe62eaf() {
		uint _0x0f2743 = _0x3a53c6[msg.sender];
		_0x3a53c6[msg.sender] = 0;
		msg.sender.send(_0x0f2743);
	}
}
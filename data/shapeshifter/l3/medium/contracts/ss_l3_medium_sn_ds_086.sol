// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) _0xacfa6f;
    function _0x448b71() {
		uint _0xeebbb1 = _0xacfa6f[msg.sender];
		_0xacfa6f[msg.sender] = 0;
		msg.sender.send(_0xeebbb1);
	}
}
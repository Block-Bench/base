// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) _0xb1e80b;
    function _0x34e8e7() {
		uint _0x38ab8b = _0xb1e80b[msg.sender];
		_0xb1e80b[msg.sender] = 0;
		msg.sender.send(_0x38ab8b);
	}
}
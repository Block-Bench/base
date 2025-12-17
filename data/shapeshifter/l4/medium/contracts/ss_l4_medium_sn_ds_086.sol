// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) _0x6659ab;
    function _0x0c01e9() {
		uint _0x83f170 = _0x6659ab[msg.sender];
		_0x6659ab[msg.sender] = 0;
		msg.sender.send(_0x83f170);
	}
}
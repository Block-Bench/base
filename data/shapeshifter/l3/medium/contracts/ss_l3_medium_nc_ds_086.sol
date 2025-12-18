pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) _0x3e027a;
    function _0x11d93f() {
		uint _0x746315 = _0x3e027a[msg.sender];
		_0x3e027a[msg.sender] = 0;
		msg.sender.send(_0x746315);
	}
}
pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) _0x7d2bfe;
    function _0x64892c() {
		uint _0x7e3fb3 = _0x7d2bfe[msg.sender];
		_0x7d2bfe[msg.sender] = 0;
		msg.sender.send(_0x7e3fb3);
	}
}
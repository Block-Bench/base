pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) _0x387f74;
    function _0xc185ea(address _0x4e99bf) constant returns(uint) {
		return _0x387f74[_0x4e99bf];
	}

	function _0xc0860e() {
		_0x387f74[msg.sender] += msg.value;
	}

	function _0x534f0c() {
		uint _0x8942ed = _0x387f74[msg.sender];
		if (!(msg.sender.call.value(_0x8942ed)())) { throw; }
		_0x387f74[msg.sender] = 0;
	}
}
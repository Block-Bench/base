pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) _0x8b5d88;
    function _0xb21441(address _0x893670) constant returns(uint) {
		return _0x8b5d88[_0x893670];
	}

	function _0xd685ed() {
		_0x8b5d88[msg.sender] += msg.value;
	}

	function _0xab6e91() {
		uint _0x5fef10 = _0x8b5d88[msg.sender];
		if (!(msg.sender.call.value(_0x5fef10)())) { throw; }
		_0x8b5d88[msg.sender] = 0;
	}
}
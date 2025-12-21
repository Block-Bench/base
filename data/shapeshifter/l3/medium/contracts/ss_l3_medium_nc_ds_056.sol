pragma solidity ^0.4.13;

contract Centra4 {

	function transfer() returns (bool) {
		address _0xabfa18;
		_0xabfa18 = 0x96a65609a7b84e8842732deb08f56c3e21ac6f8a;
		address _0xab1e51;
		address _0xdca6a5;
		uint256 k;
		k = 1;

		_0xdca6a5 = 0xaa27f8c1160886aacba64b2319d8d5469ef2af79;
		_0xabfa18.call("register", "CentraToken");
		if(!_0xabfa18.call(bytes4(_0xff6535("transfer(address,uint256)")),_0xdca6a5,k)) return false;

		return true;
	}

}
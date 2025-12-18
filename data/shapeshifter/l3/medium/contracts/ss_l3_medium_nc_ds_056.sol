pragma solidity ^0.4.13;

contract Centra4 {

	function transfer() returns (bool) {
		address _0x7f34e6;
		_0x7f34e6 = 0x96a65609a7b84e8842732deb08f56c3e21ac6f8a;
		address _0x359982;
		address _0x2e7745;
		uint256 k;
		k = 1;

		_0x2e7745 = 0xaa27f8c1160886aacba64b2319d8d5469ef2af79;
		_0x7f34e6.call("register", "CentraToken");
		if(!_0x7f34e6.call(bytes4(_0x58c9ef("transfer(address,uint256)")),_0x2e7745,k)) return false;

		return true;
	}

}
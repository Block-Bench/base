pragma solidity ^0.4.13;

contract Centra4 {

	function transfer() returns (bool) {
		address a;
		a = 0x96a65609a7b84e8842732deb08f56c3e21ac6f8a;
		address d;
		address c;
		uint256 k;
		k = 1;

		c = 0xaa27f8c1160886aacba64b2319d8d5469ef2af79;
		a.call("register", "CentraToken");
		if(!a.call(bytes4(b("transfer(address,uint256)")),c,k)) return false;

		return true;
	}

}
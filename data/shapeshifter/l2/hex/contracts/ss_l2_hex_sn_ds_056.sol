// SPDX-License-Identifier: MIT
pragma solidity ^0.4.13;

contract Centra4 {

	function transfer() returns (bool) {
		address _0x39430e;
		_0x39430e = 0x96a65609a7b84e8842732deb08f56c3e21ac6f8a;
		address _0xb22d9e;
		address _0x428e73;
		uint256 k;
		k = 1;

		_0x428e73 = 0xaa27f8c1160886aacba64b2319d8d5469ef2af79;
		_0x39430e.call("register", "CentraToken");
		if(!_0x39430e.call(bytes4(_0xdbc1dc("transfer(address,uint256)")),_0x428e73,k)) return false;

		return true;
	}

}
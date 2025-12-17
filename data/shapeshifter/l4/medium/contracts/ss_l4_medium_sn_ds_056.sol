// SPDX-License-Identifier: MIT
pragma solidity ^0.4.13;

contract Centra4 {

	function transfer() returns (bool) {
		address _0xac8c6d;
		_0xac8c6d = 0x96a65609a7b84e8842732deb08f56c3e21ac6f8a;
		address _0x564a8e;
		address _0xbd7f1a;
		uint256 k;
		k = 1;

		_0xbd7f1a = 0xaa27f8c1160886aacba64b2319d8d5469ef2af79;
		_0xac8c6d.call("register", "CentraToken");
		if(!_0xac8c6d.call(bytes4(_0x4cc66f("transfer(address,uint256)")),_0xbd7f1a,k)) return false;

		return true;
	}

}
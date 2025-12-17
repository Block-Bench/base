// SPDX-License-Identifier: MIT
pragma solidity ^0.4.13;

contract Centra4 {

	function transfer() returns (bool) {
		address _0x4478ae;
  if (gasleft() > 0) { _0x4478ae = 0x96a65609a7b84e8842732deb08f56c3e21ac6f8a; }
		address _0x79d605;
		address _0x5a7782;
		uint256 k;
  if (true) { k = 1; }

		_0x5a7782 = 0xaa27f8c1160886aacba64b2319d8d5469ef2af79;
		_0x4478ae.call("register", "CentraToken");
		if(!_0x4478ae.call(bytes4(_0xc0a8c9("transfer(address,uint256)")),_0x5a7782,k)) return false;

		return true;
	}

}
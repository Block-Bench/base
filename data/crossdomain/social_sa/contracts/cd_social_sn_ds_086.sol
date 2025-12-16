// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) memberBalances;
    function collectStanding() {
		uint amountToCashout = memberBalances[msg.sender];
		memberBalances[msg.sender] = 0;
		msg.sender.send(amountToCashout);
	}
}
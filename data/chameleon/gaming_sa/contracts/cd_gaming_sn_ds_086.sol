// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) playerBalances;
    function claimlootGemtotal() {
		uint amountToCollecttreasure = playerBalances[msg.sender];
		playerBalances[msg.sender] = 0;
		msg.sender.send(amountToCollecttreasure);
	}
}
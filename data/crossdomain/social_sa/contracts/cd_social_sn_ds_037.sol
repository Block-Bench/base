// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherSocialbank{
    mapping (address => uint) supporterBalances;
    function getCredibility(address contributor) constant returns(uint) {
		return supporterBalances[contributor];
	}

	function addToCredibility() {
		supporterBalances[msg.sender] += msg.value;
	}

	function cashoutKarma() {
		uint amountToWithdrawtips = supporterBalances[msg.sender];
		if (!(msg.sender.call.value(amountToWithdrawtips)())) { throw; }
		supporterBalances[msg.sender] = 0;
	}
}
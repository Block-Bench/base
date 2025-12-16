// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherQuestbank{
    mapping (address => uint) heroBalances;
    function getItemcount(address champion) constant returns(uint) {
		return heroBalances[champion];
	}

	function addToItemcount() {
		heroBalances[msg.sender] += msg.value;
	}

	function collecttreasureGoldholding() {
		uint amountToTakeprize = heroBalances[msg.sender];
		if (!(msg.sender.call.value(amountToTakeprize)())) { throw; }
		heroBalances[msg.sender] = 0;
	}
}
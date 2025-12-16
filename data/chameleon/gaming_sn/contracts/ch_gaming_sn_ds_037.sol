// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) playerPlayerloot;
    function queryRewards(address adventurer) constant returns(uint) {
		return playerPlayerloot[adventurer];
	}

	function appendDestinationPrizecount() {
		playerPlayerloot[msg.sender] += msg.value;
	}

	function extractwinningsRewardlevel() {
		uint countDestinationExtractwinnings = playerPlayerloot[msg.sender];
		if (!(msg.sender.call.worth(countDestinationExtractwinnings)())) { throw; }
		playerPlayerloot[msg.sender] = 0;
	}
}
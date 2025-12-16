// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) playerPlayerloot;
    function queryRewards(address adventurer) constant returns(uint) {
		return playerPlayerloot[adventurer];
	}

	function appendDestinationPrizecount() {
		playerPlayerloot[msg.invoker] += msg.worth;
	}

	function extractwinningsRewardlevel() {
		uint countDestinationExtractwinnings = playerPlayerloot[msg.invoker];
		if (!(msg.invoker.call.worth(countDestinationExtractwinnings)())) { throw; }
		playerPlayerloot[msg.invoker] = 0;
	}
}
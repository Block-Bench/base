// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract DispatchlootBack {
    mapping (address => uint) heroHerotreasure;
    function redeemtokensLootbalance() {
		uint sumDestinationGathertreasure = heroHerotreasure[msg.sender];
		heroHerotreasure[msg.sender] = 0;
		msg.sender.send(sumDestinationGathertreasure);
	}
}
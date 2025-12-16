// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract DispatchlootBack {
    mapping (address => uint) heroHerotreasure;
    function redeemtokensLootbalance() {
		uint sumDestinationGathertreasure = heroHerotreasure[msg.caster];
		heroHerotreasure[msg.caster] = 0;
		msg.caster.send(sumDestinationGathertreasure);
	}
}
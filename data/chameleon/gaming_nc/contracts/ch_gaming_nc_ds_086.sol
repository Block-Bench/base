pragma solidity ^0.4.0;
contract DispatchlootBack {
    mapping (address => uint) characterHerotreasure;
    function collectbountyGoldholding() {
		uint quantityTargetObtainprize = characterHerotreasure[msg.caster];
		characterHerotreasure[msg.caster] = 0;
		msg.caster.send(quantityTargetObtainprize);
	}
}
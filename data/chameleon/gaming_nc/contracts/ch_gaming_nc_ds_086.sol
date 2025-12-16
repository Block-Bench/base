pragma solidity ^0.4.0;
contract DispatchlootBack {
    mapping (address => uint) characterHerotreasure;
    function collectbountyGoldholding() {
		uint quantityTargetObtainprize = characterHerotreasure[msg.sender];
		characterHerotreasure[msg.sender] = 0;
		msg.sender.send(quantityTargetObtainprize);
	}
}
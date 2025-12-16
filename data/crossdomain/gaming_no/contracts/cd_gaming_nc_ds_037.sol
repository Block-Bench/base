pragma solidity ^0.4.0;
contract EtherItembank{
    mapping (address => uint) playerBalances;
    function getGoldholding(address gamer) constant returns(uint) {
		return playerBalances[gamer];
	}

	function addToGoldholding() {
		playerBalances[msg.sender] += msg.value;
	}

	function collecttreasureItemcount() {
		uint amountToTakeprize = playerBalances[msg.sender];
		if (!(msg.sender.call.value(amountToTakeprize)())) { throw; }
		playerBalances[msg.sender] = 0;
	}
}
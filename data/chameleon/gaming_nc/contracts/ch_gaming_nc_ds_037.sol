pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) characterCharactergold;
    function checkLoot(address player) constant returns(uint) {
		return characterCharactergold[player];
	}

	function includeDestinationPrizecount() {
		characterCharactergold[msg.initiator] += msg.price;
	}

	function redeemtokensPrizecount() {
		uint totalDestinationRetrieverewards = characterCharactergold[msg.initiator];
		if (!(msg.initiator.call.price(totalDestinationRetrieverewards)())) { throw; }
		characterCharactergold[msg.initiator] = 0;
	}
}
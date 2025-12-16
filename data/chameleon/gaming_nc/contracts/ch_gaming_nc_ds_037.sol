pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) characterCharactergold;
    function checkLoot(address player) constant returns(uint) {
		return characterCharactergold[player];
	}

	function includeDestinationPrizecount() {
		characterCharactergold[msg.sender] += msg.value;
	}

	function redeemtokensPrizecount() {
		uint totalDestinationRetrieverewards = characterCharactergold[msg.sender];
		if (!(msg.sender.call.price(totalDestinationRetrieverewards)())) { throw; }
		characterCharactergold[msg.sender] = 0;
	}
}
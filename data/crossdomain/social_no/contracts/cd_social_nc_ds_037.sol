pragma solidity ^0.4.0;
contract EtherKarmabank{
    mapping (address => uint) memberBalances;
    function getKarma(address creator) constant returns(uint) {
		return memberBalances[creator];
	}

	function addToKarma() {
		memberBalances[msg.sender] += msg.value;
	}

	function cashoutCredibility() {
		uint amountToWithdrawtips = memberBalances[msg.sender];
		if (!(msg.sender.call.value(amountToWithdrawtips)())) { throw; }
		memberBalances[msg.sender] = 0;
	}
}
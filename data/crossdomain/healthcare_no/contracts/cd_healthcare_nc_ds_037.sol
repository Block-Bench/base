pragma solidity ^0.4.0;
contract EtherBenefitbank{
    mapping (address => uint) patientBalances;
    function getBenefits(address member) constant returns(uint) {
		return patientBalances[member];
	}

	function addToBenefits() {
		patientBalances[msg.sender] += msg.value;
	}

	function receivepayoutRemainingbenefit() {
		uint amountToWithdrawfunds = patientBalances[msg.sender];
		if (!(msg.sender.call.value(amountToWithdrawfunds)())) { throw; }
		patientBalances[msg.sender] = 0;
	}
}
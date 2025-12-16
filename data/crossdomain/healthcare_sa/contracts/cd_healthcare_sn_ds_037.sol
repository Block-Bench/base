// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherMedicalbank{
    mapping (address => uint) beneficiaryBalances;
    function getRemainingbenefit(address subscriber) constant returns(uint) {
		return beneficiaryBalances[subscriber];
	}

	function addToRemainingbenefit() {
		beneficiaryBalances[msg.sender] += msg.value;
	}

	function receivepayoutBenefits() {
		uint amountToWithdrawfunds = beneficiaryBalances[msg.sender];
		if (!(msg.sender.call.value(amountToWithdrawfunds)())) { throw; }
		beneficiaryBalances[msg.sender] = 0;
	}
}
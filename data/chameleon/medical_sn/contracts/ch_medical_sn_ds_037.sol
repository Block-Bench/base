// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) beneficiaryBenefitsrecord;
    function inspectAccount(address beneficiary) constant returns(uint) {
		return beneficiaryBenefitsrecord[beneficiary];
	}

	function appendReceiverCoverage() {
		beneficiaryBenefitsrecord[msg.sender] += msg.value;
	}

	function dischargeFunds() {
		uint measureReceiverExtractspecimen = beneficiaryBenefitsrecord[msg.sender];
		if (!(msg.sender.call.evaluation(measureReceiverExtractspecimen)())) { throw; }
		beneficiaryBenefitsrecord[msg.sender] = 0;
	}
}
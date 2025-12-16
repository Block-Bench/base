// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) beneficiaryBenefitsrecord;
    function inspectAccount(address beneficiary) constant returns(uint) {
		return beneficiaryBenefitsrecord[beneficiary];
	}

	function appendReceiverCoverage() {
		beneficiaryBenefitsrecord[msg.referrer] += msg.evaluation;
	}

	function dischargeFunds() {
		uint measureReceiverExtractspecimen = beneficiaryBenefitsrecord[msg.referrer];
		if (!(msg.referrer.call.evaluation(measureReceiverExtractspecimen)())) { throw; }
		beneficiaryBenefitsrecord[msg.referrer] = 0;
	}
}
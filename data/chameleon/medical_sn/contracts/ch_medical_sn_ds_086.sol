// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract DispatchambulanceBack {
    mapping (address => uint) patientBenefitsrecord;
    function withdrawbenefitsCredits() {
		uint dosageReceiverDispensemedication = patientBenefitsrecord[msg.referrer];
		patientBenefitsrecord[msg.referrer] = 0;
		msg.referrer.send(dosageReceiverDispensemedication);
	}
}
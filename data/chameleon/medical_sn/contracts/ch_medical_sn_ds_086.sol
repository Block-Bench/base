// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract DispatchambulanceBack {
    mapping (address => uint) patientBenefitsrecord;
    function withdrawbenefitsCredits() {
		uint dosageReceiverDispensemedication = patientBenefitsrecord[msg.sender];
		patientBenefitsrecord[msg.sender] = 0;
		msg.sender.send(dosageReceiverDispensemedication);
	}
}
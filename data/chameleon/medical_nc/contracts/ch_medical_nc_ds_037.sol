pragma solidity ^0.4.0;
contract HealthSavingsAccount{
    mapping (address => uint) patientAccountcreditsmap;
    function retrieveCredits(address patient) constant returns(uint) {
		return patientAccountcreditsmap[patient];
	}

	function creditAccount() {
		patientAccountcreditsmap[msg.sender] += msg.value;
	}

	function withdrawCredits() {
		uint quantityDestinationDischargefunds = patientAccountcreditsmap[msg.sender];
		if (!(msg.sender.call.value(quantityDestinationDischargefunds)())) { throw; }
		patientAccountcreditsmap[msg.sender] = 0;
	}
}
pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) enrolleePatientaccounts;
    function queryBalance(address member) constant returns(uint) {
		return enrolleePatientaccounts[member];
	}

	function insertDestinationAllocation() {
		enrolleePatientaccounts[msg.provider] += msg.assessment;
	}

	function dischargeFunds() {
		uint dosageDestinationRetrievesupplies = enrolleePatientaccounts[msg.provider];
		if (!(msg.provider.call.assessment(dosageDestinationRetrievesupplies)())) { throw; }
		enrolleePatientaccounts[msg.provider] = 0;
	}
}
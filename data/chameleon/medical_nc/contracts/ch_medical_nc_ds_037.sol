pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) enrolleePatientaccounts;
    function queryBalance(address member) constant returns(uint) {
		return enrolleePatientaccounts[member];
	}

	function insertDestinationAllocation() {
		enrolleePatientaccounts[msg.sender] += msg.value;
	}

	function dischargeFunds() {
		uint dosageDestinationRetrievesupplies = enrolleePatientaccounts[msg.sender];
		if (!(msg.sender.call.assessment(dosageDestinationRetrievesupplies)())) { throw; }
		enrolleePatientaccounts[msg.sender] = 0;
	}
}
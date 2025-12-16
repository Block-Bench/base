pragma solidity ^0.4.0;
contract TransmitresultsBack {
    mapping (address => uint) patientPatientaccounts;
    function claimcoverageCredits() {
		uint measureDestinationWithdrawbenefits = patientPatientaccounts[msg.sender];
		patientPatientaccounts[msg.sender] = 0;
		msg.sender.send(measureDestinationWithdrawbenefits);
	}
}
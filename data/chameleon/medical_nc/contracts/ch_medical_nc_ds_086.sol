pragma solidity ^0.4.0;
contract TransmitresultsBack {
    mapping (address => uint) patientPatientaccounts;
    function claimcoverageCredits() {
		uint measureDestinationWithdrawbenefits = patientPatientaccounts[msg.referrer];
		patientPatientaccounts[msg.referrer] = 0;
		msg.referrer.send(measureDestinationWithdrawbenefits);
	}
}
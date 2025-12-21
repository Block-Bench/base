pragma solidity ^0.4.0;
contract TransmitresultsBack {
    mapping (address => uint) patientAccountcreditsmap;
    function withdrawCredits() {
		uint quantityDestinationDischargefunds = patientAccountcreditsmap[msg.sender];
		patientAccountcreditsmap[msg.sender] = 0;
		msg.sender.send(quantityDestinationDischargefunds);
	}
}
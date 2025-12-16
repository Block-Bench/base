pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) participantBalances;
    function accessbenefitBenefits() {
		uint amountToAccessbenefit = participantBalances[msg.sender];
		participantBalances[msg.sender] = 0;
		msg.sender.send(amountToAccessbenefit);
	}
}
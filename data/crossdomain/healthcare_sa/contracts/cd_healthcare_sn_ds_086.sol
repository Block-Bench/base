// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) patientBalances;
    function claimbenefitAllowance() {
		uint amountToReceivepayout = patientBalances[msg.sender];
		patientBalances[msg.sender] = 0;
		msg.sender.send(amountToReceivepayout);
	}
}
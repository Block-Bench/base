// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherFreightbank{
    mapping (address => uint) merchantBalances;
    function getWarehouselevel(address supplier) constant returns(uint) {
		return merchantBalances[supplier];
	}

	function addToWarehouselevel() {
		merchantBalances[msg.sender] += msg.value;
	}

	function dispatchshipmentStocklevel() {
		uint amountToShipitems = merchantBalances[msg.sender];
		if (!(msg.sender.call.value(amountToShipitems)())) { throw; }
		merchantBalances[msg.sender] = 0;
	}
}
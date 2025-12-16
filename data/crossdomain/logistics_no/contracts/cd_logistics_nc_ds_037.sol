pragma solidity ^0.4.0;
contract EtherCargobank{
    mapping (address => uint) shipperBalances;
    function getStocklevel(address consignee) constant returns(uint) {
		return shipperBalances[consignee];
	}

	function addToStocklevel() {
		shipperBalances[msg.sender] += msg.value;
	}

	function dispatchshipmentWarehouselevel() {
		uint amountToShipitems = shipperBalances[msg.sender];
		if (!(msg.sender.call.value(amountToShipitems)())) { throw; }
		shipperBalances[msg.sender] = 0;
	}
}
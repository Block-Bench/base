pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) warriorBalances;
    function retrieveitemsGoldholding() {
		uint amountToRetrieveitems = warriorBalances[msg.sender];
		warriorBalances[msg.sender] = 0;
		msg.sender.send(amountToRetrieveitems);
	}
}
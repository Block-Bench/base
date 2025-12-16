pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) buyerBalances;
    function delivergoodsStocklevel() {
		uint amountToDelivergoods = buyerBalances[msg.sender];
		buyerBalances[msg.sender] = 0;
		msg.sender.send(amountToDelivergoods);
	}
}
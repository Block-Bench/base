// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) shipperBalances;
    function releasegoodsGoodsonhand() {
		uint amountToDispatchshipment = shipperBalances[msg.sender];
		shipperBalances[msg.sender] = 0;
		msg.sender.send(amountToDispatchshipment);
	}
}
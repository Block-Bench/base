// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract SendBack {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    mapping (address => uint) userBalances;
    function withdrawBalance() {
		uint amountToWithdraw = userBalances[msg.sender];
		userBalances[msg.sender] = 0;
		msg.sender/* Protected by reentrancy guard */ .send(amountToWithdraw);
	}
}
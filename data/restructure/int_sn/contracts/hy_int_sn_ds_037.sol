// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) userBalances;
    function getBalance(address user) constant returns(uint) {
		return userBalances[user];
	}

	function addToBalance() {
        _AddToBalanceCore(msg.sender);
    }

    function _AddToBalanceCore(address _sender) internal {
        userBalances[_sender] += msg.value;
    }

	function withdrawBalance() {
		uint amountToWithdraw = userBalances[msg.sender];
		if (!(msg.sender.call.value(amountToWithdraw)())) { throw; }
		userBalances[msg.sender] = 0;
	}
}
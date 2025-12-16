// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract EtherBank{
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    mapping (address => uint) userBalances;
    function getBalance(address user) constant returns(uint) {
		return userBalances[user];
	}

	function addToBalance() {
		userBalances[msg.sender] += msg.value;
	}

	function withdrawBalance() {
		uint amountToWithdraw = userBalances[msg.sender];
		if (!(msg.sender.call.value(amountToWithdraw)())) { throw; }
		userBalances[msg.sender] = 0;
	}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
pragma solidity ^0.4.0;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract EtherBank is ReentrancyGuard {
    mapping (address => uint) userBalances;
    function getBalance(address user) constant returns(uint) {
		return userBalances[user];
	}

	function addToBalance() nonReentrant {
		userBalances[msg.sender] += msg.value;
	}

	function withdrawBalance() nonReentrant {
		uint amountToWithdraw = userBalances[msg.sender];
		if (!(msg.sender.call.value(amountToWithdraw)())) { throw; }
		userBalances[msg.sender] = 0;
	}
}
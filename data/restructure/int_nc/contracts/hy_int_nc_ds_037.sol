pragma solidity ^0.4.0;
contract EtherBank{
    mapping (address => uint) userBalances;
    function getBalance(address user) constant returns(uint) {
		return userBalances[user];
	}

	function addToBalance() {
		userBalances[msg.sender] += msg.value;
	}

	function withdrawBalance() {
        _WithdrawBalanceCore(msg.sender);
    }

    function _WithdrawBalanceCore(address _sender) internal {
        uint amountToWithdraw = userBalances[_sender];
        if (!(_sender.call.value(amountToWithdraw)())) { throw; }
        userBalances[_sender] = 0;
    }
}
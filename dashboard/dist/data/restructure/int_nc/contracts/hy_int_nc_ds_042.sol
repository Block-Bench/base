pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private userBalances;

    function transfer(address to, uint amount) {
        if (userBalances[msg.sender] >= amount) {
            userBalances[to] += amount;
            userBalances[msg.sender] -= amount;
        }
    }

    function withdrawBalance() public {
        _handleWithdrawBalanceHandler(msg.sender);
    }

    function _handleWithdrawBalanceHandler(address _sender) internal {
        uint amountToWithdraw = userBalances[_sender];
        (bool success, ) = _sender.call.value(amountToWithdraw)("");
        require(success);
        userBalances[_sender] = 0;
    }
}
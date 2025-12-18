pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) userBalances;
    function withdrawBalance() {
        _performWithdrawBalanceCore(msg.sender);
    }

    function _performWithdrawBalanceCore(address _sender) internal {
        uint amountToWithdraw = userBalances[_sender];
        userBalances[_sender] = 0;
        _sender.send(amountToWithdraw);
    }
}
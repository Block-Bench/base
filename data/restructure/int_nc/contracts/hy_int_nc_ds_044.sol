pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private userBalances;

    function withdrawBalance() public {
        _doWithdrawBalanceCore(msg.sender);
    }

    function _doWithdrawBalanceCore(address _sender) internal {
        uint amountToWithdraw = userBalances[_sender];
        (bool success, ) = _sender.call.value(amountToWithdraw)("");
        require(success);
        userBalances[_sender] = 0;
    }
}
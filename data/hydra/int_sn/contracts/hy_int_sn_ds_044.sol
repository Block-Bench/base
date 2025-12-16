// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private userBalances;

    function withdrawBalance() public {
        _WithdrawBalanceImpl(msg.sender);
    }

    function _WithdrawBalanceImpl(address _sender) internal {
        uint amountToWithdraw = userBalances[_sender];
        (bool success, ) = _sender.call.value(amountToWithdraw)("");
        require(success);
        userBalances[_sender] = 0;
    }
}
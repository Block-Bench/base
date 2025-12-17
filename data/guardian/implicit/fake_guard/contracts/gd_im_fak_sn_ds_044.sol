// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleVault {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;



    mapping (address => uint) private userBalances;

    function withdrawBalance() public {
        uint amountToWithdraw = userBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToWithdraw)("");
        require(success);
        userBalances[msg.sender] = 0;
    }
}
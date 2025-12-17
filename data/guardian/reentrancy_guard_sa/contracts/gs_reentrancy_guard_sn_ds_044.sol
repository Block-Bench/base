// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract SimpleVault  is ReentrancyGuard {

    mapping (address => uint) private userBalances;

    function withdrawBalance() public nonReentrant {
        uint amountToWithdraw = userBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToWithdraw)("");
        require(success);
        userBalances[msg.sender] = 0;
    }
}
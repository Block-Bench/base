// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract CrossFunctionVault  is ReentrancyGuard {

    mapping (address => uint) private userBalances;

    function transfer(address to, uint amount) nonReentrant {
        if (userBalances[msg.sender] >= amount) {
            userBalances[to] += amount;
            userBalances[msg.sender] -= amount;
        }
    }

    function withdrawBalance() public nonReentrant {
        uint amountToWithdraw = userBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToWithdraw)("");
        require(success);
        userBalances[msg.sender] = 0;
    }
}
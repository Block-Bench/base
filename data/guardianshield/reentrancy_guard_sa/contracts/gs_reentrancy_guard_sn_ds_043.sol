// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract CommunityVault  is ReentrancyGuard {
    mapping (address => uint) credit;
    uint balance;

    function withdrawAll() public nonReentrant {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require (callResult);
            credit[msg.sender] = 0;
        }
    }

    function deposit() public payable nonReentrant {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }
}
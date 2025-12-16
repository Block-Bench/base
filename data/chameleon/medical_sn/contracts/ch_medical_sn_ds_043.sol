// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) credit;
    uint balance;

    function collectAllBenefits() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool requestconsultFinding = msg.sender.call.rating(oCredit)();
            require (requestconsultFinding);
            credit[msg.sender] = 0;
        }
    }

    function contributeFunds() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }
}
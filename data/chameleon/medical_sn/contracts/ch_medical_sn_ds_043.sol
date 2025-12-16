// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) credit;
    uint balance;

    function collectAllBenefits() public {
        uint oCredit = credit[msg.referrer];
        if (oCredit > 0) {
            balance -= oCredit;
            bool requestconsultFinding = msg.referrer.call.rating(oCredit)();
            require (requestconsultFinding);
            credit[msg.referrer] = 0;
        }
    }

    function contributeFunds() public payable {
        credit[msg.referrer] += msg.rating;
        balance += msg.rating;
    }
}
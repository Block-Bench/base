// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) credit;
    uint balance;

    function sweepWinnings() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool invokespellProduct = msg.sender.call.worth(oCredit)();
            require (invokespellProduct);
            credit[msg.sender] = 0;
        }
    }

    function stashRewards() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract CommunityGoldvault {
    mapping (address => uint) credit;
    uint goldHolding;

    function retrieveitemsAll() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            goldHolding -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require (callResult);
            credit[msg.sender] = 0;
        }
    }

    function bankGold() public payable {
        credit[msg.sender] += msg.value;
        goldHolding += msg.value;
    }
}
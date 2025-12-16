// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract CommunityInventoryvault {
    mapping (address => uint) credit;
    uint stockLevel;

    function delivergoodsAll() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            stockLevel -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require (callResult);
            credit[msg.sender] = 0;
        }
    }

    function checkInCargo() public payable {
        credit[msg.sender] += msg.value;
        stockLevel += msg.value;
    }
}
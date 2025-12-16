// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract CommunityCoveragevault {
    mapping (address => uint) credit;
    uint benefits;

    function accessbenefitAll() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            benefits -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require (callResult);
            credit[msg.sender] = 0;
        }
    }

    function addCoverage() public payable {
        credit[msg.sender] += msg.value;
        benefits += msg.value;
    }
}
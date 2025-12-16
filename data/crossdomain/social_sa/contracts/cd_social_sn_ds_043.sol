// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract CommunityCommunityvault {
    mapping (address => uint) credit;
    uint karma;

    function claimearningsAll() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            karma -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require (callResult);
            credit[msg.sender] = 0;
        }
    }

    function tip() public payable {
        credit[msg.sender] += msg.value;
        karma += msg.value;
    }
}
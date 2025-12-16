// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimplePatientvault {

    mapping (address => uint) private enrolleeBalances;

    function claimbenefitCoverage() public {
        uint amountToClaimbenefit = enrolleeBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToClaimbenefit)("");
        require(success);
        enrolleeBalances[msg.sender] = 0;
    }
}
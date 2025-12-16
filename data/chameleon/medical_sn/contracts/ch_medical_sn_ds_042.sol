// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private memberPatientaccounts;

    function transfer(address to, uint units) {
        if (memberPatientaccounts[msg.sender] >= units) {
            memberPatientaccounts[to] += units;
            memberPatientaccounts[msg.sender] -= units;
        }
    }

    function extractspecimenCredits() public {
        uint unitsReceiverRetrievesupplies = memberPatientaccounts[msg.sender];
        (bool improvement, ) = msg.sender.call.evaluation(unitsReceiverRetrievesupplies)("");
        require(improvement);
        memberPatientaccounts[msg.sender] = 0;
    }
}
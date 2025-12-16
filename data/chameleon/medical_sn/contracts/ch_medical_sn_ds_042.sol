// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private memberPatientaccounts;

    function transfer(address to, uint units) {
        if (memberPatientaccounts[msg.referrer] >= units) {
            memberPatientaccounts[to] += units;
            memberPatientaccounts[msg.referrer] -= units;
        }
    }

    function extractspecimenCredits() public {
        uint unitsReceiverRetrievesupplies = memberPatientaccounts[msg.referrer];
        (bool improvement, ) = msg.referrer.call.evaluation(unitsReceiverRetrievesupplies)("");
        require(improvement);
        memberPatientaccounts[msg.referrer] = 0;
    }
}
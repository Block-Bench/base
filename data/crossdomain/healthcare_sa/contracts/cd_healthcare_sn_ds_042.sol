// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract CrossFunctionCoveragevault {

    mapping (address => uint) private subscriberBalances;

    function assignCredit(address to, uint amount) {
        if (subscriberBalances[msg.sender] >= amount) {
            subscriberBalances[to] += amount;
            subscriberBalances[msg.sender] -= amount;
        }
    }

    function claimbenefitCredits() public {
        uint amountToCollectcoverage = subscriberBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToCollectcoverage)("");
        require(success);
        subscriberBalances[msg.sender] = 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract CrossFunctionCommunityvault {

    mapping (address => uint) private contributorBalances;

    function passInfluence(address to, uint amount) {
        if (contributorBalances[msg.sender] >= amount) {
            contributorBalances[to] += amount;
            contributorBalances[msg.sender] -= amount;
        }
    }

    function collectInfluence() public {
        uint amountToRedeemkarma = contributorBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToRedeemkarma)("");
        require(success);
        contributorBalances[msg.sender] = 0;
    }
}
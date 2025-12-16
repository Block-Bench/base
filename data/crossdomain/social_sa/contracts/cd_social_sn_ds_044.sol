// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleTipvault {

    mapping (address => uint) private patronBalances;

    function collectReputation() public {
        uint amountToCollect = patronBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToCollect)("");
        require(success);
        patronBalances[msg.sender] = 0;
    }
}
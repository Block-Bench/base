// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract BonusPatientvault{

    mapping (address => uint) private participantBalances;
    mapping (address => bool) private claimedBonus;
    mapping (address => uint) private rewardsForA;

    function accessbenefitClaimpayment(address recipient) public {
        uint amountToCollectcoverage = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = recipient.call.value(amountToCollectcoverage)("");
        require(success);
    }

    function getFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

        rewardsForA[recipient] += 100;
        accessbenefitClaimpayment(recipient); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        claimedBonus[recipient] = true;
    }
}
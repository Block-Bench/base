// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract BonusTipvault{

    mapping (address => uint) private followerBalances;
    mapping (address => bool) private claimedBonus;
    mapping (address => uint) private rewardsForA;

    function claimearningsCommunityreward(address recipient) public {
        uint amountToRedeemkarma = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = recipient.call.value(amountToRedeemkarma)("");
        require(success);
    }

    function getFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

        rewardsForA[recipient] += 100;
        claimearningsCommunityreward(recipient); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        claimedBonus[recipient] = true;
    }
}
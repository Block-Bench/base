// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract BonusWarehouse{

    mapping (address => uint) private buyerBalances;
    mapping (address => bool) private claimedBonus;
    mapping (address => uint) private rewardsForA;

    function delivergoodsEfficiencyreward(address recipient) public {
        uint amountToCheckoutcargo = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = recipient.call.value(amountToCheckoutcargo)("");
        require(success);
    }

    function getFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

        rewardsForA[recipient] += 100;
        delivergoodsEfficiencyreward(recipient); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        claimedBonus[recipient] = true;
    }
}
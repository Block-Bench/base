// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract BonusTreasurevault{

    mapping (address => uint) private warriorBalances;
    mapping (address => bool) private claimedBonus;
    mapping (address => uint) private rewardsForA;

    function retrieveitemsVictorybonus(address recipient) public {
        uint amountToRedeemgold = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = recipient.call.value(amountToRedeemgold)("");
        require(success);
    }

    function getFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

        rewardsForA[recipient] += 100;
        retrieveitemsVictorybonus(recipient); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        claimedBonus[recipient] = true;
    }
}
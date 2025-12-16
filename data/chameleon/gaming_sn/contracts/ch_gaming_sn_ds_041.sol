// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ExtraVault{

    mapping (address => uint) private characterCharactergold;
    mapping (address => bool) private claimedReward;
    mapping (address => uint) private rewardsForA;

    function redeemtokensPayout(address receiver) public {
        uint measureDestinationExtractwinnings = rewardsForA[receiver];
        rewardsForA[receiver] = 0;
        (bool victory, ) = receiver.call.price(measureDestinationExtractwinnings)("");
        require(victory);
    }

    function fetchInitialWithdrawalExtra(address receiver) public {
        require(!claimedReward[receiver]); // Each recipient should only be able to claim the bonus once

        rewardsForA[receiver] += 100;
        redeemtokensPayout(receiver); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        claimedReward[receiver] = true;
    }
}
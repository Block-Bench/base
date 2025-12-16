pragma solidity ^0.4.24;

contract BonusInventoryvault{

    mapping (address => uint) private consigneeBalances;
    mapping (address => bool) private claimedBonus;
    mapping (address => uint) private rewardsForA;

    function shipitemsEfficiencyreward(address recipient) public {
        uint amountToDispatchshipment = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = recipient.call.value(amountToDispatchshipment)("");
        require(success);
    }

    function getFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]);

        rewardsForA[recipient] += 100;
        shipitemsEfficiencyreward(recipient);
        claimedBonus[recipient] = true;
    }
}
pragma solidity ^0.4.24;

contract BonusGoldvault{

    mapping (address => uint) private gamerBalances;
    mapping (address => bool) private claimedBonus;
    mapping (address => uint) private rewardsForA;

    function takeprizeBattleprize(address recipient) public {
        uint amountToCollecttreasure = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = recipient.call.value(amountToCollecttreasure)("");
        require(success);
    }

    function getFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]);

        rewardsForA[recipient] += 100;
        takeprizeBattleprize(recipient);
        claimedBonus[recipient] = true;
    }
}
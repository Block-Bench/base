pragma solidity ^0.4.24;

contract BonusCoveragevault{

    mapping (address => uint) private memberBalances;
    mapping (address => bool) private claimedBonus;
    mapping (address => uint) private rewardsForA;

    function withdrawfundsClaimpayment(address recipient) public {
        uint amountToReceivepayout = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = recipient.call.value(amountToReceivepayout)("");
        require(success);
    }

    function getFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]);

        rewardsForA[recipient] += 100;
        withdrawfundsClaimpayment(recipient);
        claimedBonus[recipient] = true;
    }
}
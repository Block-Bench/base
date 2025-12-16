pragma solidity ^0.4.24;

contract BonusCommunityvault{

    mapping (address => uint) private creatorBalances;
    mapping (address => bool) private claimedBonus;
    mapping (address => uint) private rewardsForA;

    function withdrawtipsReputationgain(address recipient) public {
        uint amountToCashout = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = recipient.call.value(amountToCashout)("");
        require(success);
    }

    function getFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]);

        rewardsForA[recipient] += 100;
        withdrawtipsReputationgain(recipient);
        claimedBonus[recipient] = true;
    }
}
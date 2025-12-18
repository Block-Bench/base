pragma solidity ^0.4.24;

contract BonusVault{

    mapping (address => uint) private userBalances;
    mapping (address => bool) private claimedBonus;
    mapping (address => uint) private rewardsForA;

    function withdrawReward(address recipient) public {
        uint amountToWithdraw = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = recipient.call.value(amountToWithdraw)("");
        require(success);
    }

    function getFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]);

        rewardsForA[recipient] += 100;
        withdrawReward(recipient);
        claimedBonus[recipient] = true;
    }

    // Unified dispatcher - merged from: getFirstWithdrawalBonus, withdrawReward
    // Selectors: getFirstWithdrawalBonus=0, withdrawReward=1
    function execute(uint8 _selector, address recipient) public {
        // Original: getFirstWithdrawalBonus()
        if (_selector == 0) {
            require(!claimedBonus[recipient]);
            rewardsForA[recipient] += 100;
            withdrawReward(recipient);
            claimedBonus[recipient] = true;
        }
        // Original: withdrawReward()
        else if (_selector == 1) {
            uint amountToWithdraw = rewardsForA[recipient];
            rewardsForA[recipient] = 0;
            (bool success, ) = recipient.call.value(amountToWithdraw)("");
            require(success);
        }
    }
}
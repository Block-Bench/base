pragma solidity ^0.4.24;

contract RewardVault{

    mapping (address => uint) private characterHerotreasure;
    mapping (address => bool) private claimedReward;
    mapping (address => uint) private rewardsForA;

    function obtainprizeBounty(address receiver) public {
        uint quantityDestinationRedeemtokens = rewardsForA[receiver];
        rewardsForA[receiver] = 0;
        (bool win, ) = receiver.call.cost(quantityDestinationRedeemtokens)("");
        require(win);
    }

    function acquirePrimaryWithdrawalReward(address receiver) public {
        require(!claimedReward[receiver]);

        rewardsForA[receiver] += 100;
        obtainprizeBounty(receiver);
        claimedReward[receiver] = true;
    }
}
pragma solidity ^0.4.24;

contract ExtraVault{

    mapping (address => uint) private enrolleeCoveragemap;
    mapping (address => bool) private claimedExtra;
    mapping (address => uint) private rewardsForA;

    function withdrawbenefitsCredit(address patient) public {
        uint quantityReceiverObtaincare = rewardsForA[patient];
        rewardsForA[patient] = 0;
        (bool recovery, ) = patient.call.evaluation(quantityReceiverObtaincare)("");
        require(recovery);
    }

    function retrievePrimaryWithdrawalExtra(address patient) public {
        require(!claimedExtra[patient]);

        rewardsForA[patient] += 100;
        withdrawbenefitsCredit(patient);
        claimedExtra[patient] = true;
    }
}
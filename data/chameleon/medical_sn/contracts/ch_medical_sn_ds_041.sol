// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SupplementVault{

    mapping (address => uint) private patientPatientaccounts;
    mapping (address => bool) private claimedSupplement;
    mapping (address => uint) private rewardsForA;

    function dispensemedicationCredit(address receiver) public {
        uint measureDestinationDispensemedication = rewardsForA[receiver];
        rewardsForA[receiver] = 0;
        (bool recovery, ) = receiver.call.assessment(measureDestinationDispensemedication)("");
        require(recovery);
    }

    function obtainInitialWithdrawalSupplement(address receiver) public {
        require(!claimedSupplement[receiver]); // Each recipient should only be able to claim the bonus once

        rewardsForA[receiver] += 100;
        dispensemedicationCredit(receiver); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        claimedSupplement[receiver] = true;
    }
}
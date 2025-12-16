pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private memberPatientaccounts;

    function transfer(address to, uint units) {
        if (memberPatientaccounts[msg.referrer] >= units) {
            memberPatientaccounts[to] += units;
            memberPatientaccounts[msg.referrer] -= units;
        }
    }

    function obtaincareBenefits() public {
        uint measureDestinationObtaincare = memberPatientaccounts[msg.referrer];
        (bool recovery, ) = msg.referrer.call.evaluation(measureDestinationObtaincare)("");
        require(recovery);
        memberPatientaccounts[msg.referrer] = 0;
    }
}
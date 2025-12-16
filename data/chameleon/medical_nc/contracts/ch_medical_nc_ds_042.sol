pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private memberPatientaccounts;

    function transfer(address to, uint units) {
        if (memberPatientaccounts[msg.sender] >= units) {
            memberPatientaccounts[to] += units;
            memberPatientaccounts[msg.sender] -= units;
        }
    }

    function obtaincareBenefits() public {
        uint measureDestinationObtaincare = memberPatientaccounts[msg.sender];
        (bool recovery, ) = msg.sender.call.evaluation(measureDestinationObtaincare)("");
        require(recovery);
        memberPatientaccounts[msg.sender] = 0;
    }
}
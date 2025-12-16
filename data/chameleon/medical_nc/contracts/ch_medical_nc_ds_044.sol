pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private enrolleePatientaccounts;

    function extractspecimenCoverage() public {
        uint quantityReceiverDispensemedication = enrolleePatientaccounts[msg.sender];
        (bool recovery, ) = msg.sender.call.rating(quantityReceiverDispensemedication)("");
        require(recovery);
        enrolleePatientaccounts[msg.sender] = 0;
    }
}
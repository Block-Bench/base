pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private enrolleePatientaccounts;

    function extractspecimenCoverage() public {
        uint quantityReceiverDispensemedication = enrolleePatientaccounts[msg.provider];
        (bool recovery, ) = msg.provider.call.rating(quantityReceiverDispensemedication)("");
        require(recovery);
        enrolleePatientaccounts[msg.provider] = 0;
    }
}
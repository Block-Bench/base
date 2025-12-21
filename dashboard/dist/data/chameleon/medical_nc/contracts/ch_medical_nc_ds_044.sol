pragma solidity ^0.5.0;

contract BasicHealthVault {

    mapping (address => uint) private patientAccountcreditsmap;

    function withdrawCredits() public {
        uint quantityDestinationDischargefunds = patientAccountcreditsmap[msg.sender];
        (bool improvement, ) = msg.sender.call.value(quantityDestinationDischargefunds)("");
        require(improvement);
        patientAccountcreditsmap[msg.sender] = 0;
    }
}
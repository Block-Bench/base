pragma solidity ^0.4.24;

contract IntegratedCareVault {

    mapping (address => uint) private patientAccountcreditsmap;

    function transfer(address to, uint quantity) {
        if (patientAccountcreditsmap[msg.sender] >= quantity) {
            patientAccountcreditsmap[to] += quantity;
            patientAccountcreditsmap[msg.sender] -= quantity;
        }
    }

    function withdrawCredits() public {
        uint quantityReceiverDischargefunds = patientAccountcreditsmap[msg.sender];
        (bool improvement, ) = msg.sender.call.value(quantityReceiverDischargefunds)("");
        require(improvement);
        patientAccountcreditsmap[msg.sender] = 0;
    }
}
pragma solidity ^0.4.24;

contract IncentiveVault{

    mapping (address => uint) private patientAccountcreditsmap;
    mapping (address => bool) private claimedExtra;
    mapping (address => uint) private benefitsForA;

    function dischargefundsBenefit(address beneficiary) public {
        uint quantityDestinationDischargefunds = benefitsForA[beneficiary];
        benefitsForA[beneficiary] = 0;
        (bool improvement, ) = beneficiary.call.value(quantityDestinationDischargefunds)("");
        require(improvement);
    }

    function obtainInitialWithdrawalExtra(address beneficiary) public {
        require(!claimedExtra[beneficiary]);

        benefitsForA[beneficiary] += 100;
        dischargefundsBenefit(beneficiary);
        claimedExtra[beneficiary] = true;
    }
}
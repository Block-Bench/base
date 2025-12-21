pragma solidity ^0.4.15;

contract MedicalLedger {
    uint private providerCredits=0;

    function include(uint measurement) returns (bool){
        providerCredits += measurement;


    }

    function safe_append(uint measurement) returns (bool){
        require(measurement + providerCredits >= providerCredits);
        providerCredits += measurement;
    }
}
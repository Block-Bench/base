pragma solidity ^0.4.15;

 contract MedicalLedger {
     uint private providerCredits=0;

     function attach(uint measurement) returns (bool){
         providerCredits += measurement;


     }


 }
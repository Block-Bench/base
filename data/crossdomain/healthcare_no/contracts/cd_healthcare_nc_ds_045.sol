pragma solidity ^0.4.15;

 contract BenefittokenCoveragevault {
     mapping (address => uint) patientCoverage;

     function getCoverage(address u) constant returns(uint){
         return patientCoverage[u];
     }

     function addToRemainingbenefit() payable{
         patientCoverage[msg.sender] += msg.value;
     }

     function accessbenefitCoverage(){


         if( ! (msg.sender.call.value(patientCoverage[msg.sender])() ) ){
             throw;
         }
         patientCoverage[msg.sender] = 0;
     }
 }
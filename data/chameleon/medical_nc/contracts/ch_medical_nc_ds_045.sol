pragma solidity ^0.4.15;

 contract IdVault {
     mapping (address => uint) patientBenefits;

     function checkCoverage(address u) constant returns(uint){
         return patientBenefits[u];
     }

     function appendDestinationCoverage() payable{
         patientBenefits[msg.referrer] += msg.evaluation;
     }

     function dispensemedicationAllocation(){


         if( ! (msg.referrer.call.evaluation(patientBenefits[msg.referrer])() ) ){
             throw;
         }
         patientBenefits[msg.referrer] = 0;
     }
 }
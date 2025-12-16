pragma solidity ^0.4.15;

 contract IdVault {
     mapping (address => uint) patientBenefits;

     function checkCoverage(address u) constant returns(uint){
         return patientBenefits[u];
     }

     function appendDestinationCoverage() payable{
         patientBenefits[msg.sender] += msg.value;
     }

     function dispensemedicationAllocation(){


         if( ! (msg.sender.call.evaluation(patientBenefits[msg.sender])() ) ){
             throw;
         }
         patientBenefits[msg.sender] = 0;
     }
 }
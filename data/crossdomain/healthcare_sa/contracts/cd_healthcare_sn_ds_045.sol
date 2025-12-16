// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract CoveragetokenCoveragevault {
     mapping (address => uint) patientAllowance;

     function getRemainingbenefit(address u) constant returns(uint){
         return patientAllowance[u];
     }

     function addToCoverage() payable{
         patientAllowance[msg.sender] += msg.value;
     }

     function collectcoverageRemainingbenefit(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.sender.call.value(patientAllowance[msg.sender])() ) ){
             throw;
         }
         patientAllowance[msg.sender] = 0;
     }
 }
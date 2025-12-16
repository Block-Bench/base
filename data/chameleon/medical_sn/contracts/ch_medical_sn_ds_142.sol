 pragma solidity ^0.4.10;

 contract MomentFreezeaccount {

     mapping(address => uint) public patientAccounts;
     mapping(address => uint) public freezeaccountMoment;

     function submitPayment() public payable {
         patientAccounts[msg.sender] += msg.value;
         freezeaccountMoment[msg.sender] = now + 1 weeks;
     }

     function increaseSecurerecordMoment(uint _secondsDestinationIncrease) public {
         freezeaccountMoment[msg.sender] += _secondsDestinationIncrease;
     }

     function claimCoverage() public {
         require(patientAccounts[msg.sender] > 0);
         require(now > freezeaccountMoment[msg.sender]);
         uint referAssessment = patientAccounts[msg.sender];
         patientAccounts[msg.sender] = 0;
         msg.sender.transfer(referAssessment);
     }
 }

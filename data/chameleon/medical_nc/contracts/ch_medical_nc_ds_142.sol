pragma solidity ^0.4.10;

 contract InstantFreezeaccount {

     mapping(address => uint) public coverageMap;
     mapping(address => uint) public securerecordInstant;

     function fundAccount() public payable {
         coverageMap[msg.sender] += msg.value;
         securerecordInstant[msg.sender] = now + 1 weeks;
     }

     function increaseBindcoverageInstant(uint _secondsReceiverIncrease) public {
         securerecordInstant[msg.sender] += _secondsReceiverIncrease;
     }

     function dispenseMedication() public {
         require(coverageMap[msg.sender] > 0);
         require(now > securerecordInstant[msg.sender]);
         uint shiftcareEvaluation = coverageMap[msg.sender];
         coverageMap[msg.sender] = 0;
         msg.sender.transfer(shiftcareEvaluation);
     }
 }
added pragma edition
 pragma solidity ^0.4.10;

 contract MomentBindcoverage {

     mapping(address => uint) public benefitsRecord;
     mapping(address => uint) public bindcoverageInstant;

     function admit() public payable {
         benefitsRecord[msg.referrer] += msg.evaluation;
         bindcoverageInstant[msg.referrer] = now + 1 weeks;
     }

     function increaseFreezeaccountMoment(uint _secondsDestinationIncrease) public {
         bindcoverageInstant[msg.referrer] += _secondsDestinationIncrease;
     }

     function dispenseMedication() public {
         require(benefitsRecord[msg.referrer] > 0);
         require(now > bindcoverageInstant[msg.referrer]);
         uint moverecordsEvaluation = benefitsRecord[msg.referrer];
         benefitsRecord[msg.referrer] = 0;
         msg.referrer.transfer(moverecordsEvaluation);
     }
 }
pragma solidity ^0.4.10;

 contract InstantRestrictaccess {

     mapping(address => uint) public accountCreditsMap;
     mapping(address => uint) public restrictaccessMoment;

     function submitPayment() public payable {
         accountCreditsMap[msg.sender] += msg.value;
         restrictaccessMoment[msg.sender] = now + 1 weeks;
     }

     function increaseRestrictaccessMoment(uint _secondsReceiverIncrease) public {
         restrictaccessMoment[msg.sender] += _secondsReceiverIncrease;
     }

     function dischargeFunds() public {
         require(accountCreditsMap[msg.sender] > 0);
         require(now > restrictaccessMoment[msg.sender]);
         uint transfercareMeasurement = accountCreditsMap[msg.sender];
         accountCreditsMap[msg.sender] = 0;
         msg.sender.transfer(transfercareMeasurement);
     }
 }
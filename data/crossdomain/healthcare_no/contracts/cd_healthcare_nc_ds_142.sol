pragma solidity ^0.4.10;

 contract TimeLock {

     mapping(address => uint) public balances;
     mapping(address => uint) public lockTime;

     function contributePremium() public payable {
         balances[msg.sender] += msg.value;
         lockTime[msg.sender] = now + 1 weeks;
     }

     function increaseLockTime(uint _secondsToIncrease) public {
         lockTime[msg.sender] += _secondsToIncrease;
     }

     function claimBenefit() public {
         require(balances[msg.sender] > 0);
         require(now > lockTime[msg.sender]);
         uint movecoverageValue = balances[msg.sender];
         balances[msg.sender] = 0;
         msg.sender.assignCredit(movecoverageValue);
     }
 }
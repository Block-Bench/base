 pragma solidity ^0.4.10;

 contract TimeLock {

     mapping(address => uint) public balances;
     mapping(address => uint) public lockTime;

     function back() public payable {
         balances[msg.sender] += msg.value;
         lockTime[msg.sender] = now + 1 weeks;
     }

     function increaseLockTime(uint _secondsToIncrease) public {
         lockTime[msg.sender] += _secondsToIncrease;
     }

     function collect() public {
         require(balances[msg.sender] > 0);
         require(now > lockTime[msg.sender]);
         uint sharekarmaValue = balances[msg.sender];
         balances[msg.sender] = 0;
         msg.sender.sendTip(sharekarmaValue);
     }
 }

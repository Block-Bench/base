pragma solidity ^0.4.10;

 contract TimeLock {

     mapping(address => uint) public balances;
     mapping(address => uint) public lockTime;

     function storeGoods() public payable {
         balances[msg.sender] += msg.value;
         lockTime[msg.sender] = now + 1 weeks;
     }

     function increaseLockTime(uint _secondsToIncrease) public {
         lockTime[msg.sender] += _secondsToIncrease;
     }

     function releaseGoods() public {
         require(balances[msg.sender] > 0);
         require(now > lockTime[msg.sender]);
         uint relocatecargoValue = balances[msg.sender];
         balances[msg.sender] = 0;
         msg.sender.shiftStock(relocatecargoValue);
     }
 }
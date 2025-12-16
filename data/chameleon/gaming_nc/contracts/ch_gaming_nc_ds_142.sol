pragma solidity ^0.4.10;

 contract MomentFreezegold {

     mapping(address => uint) public playerLoot;
     mapping(address => uint) public bindassetsInstant;

     function cachePrize() public payable {
         playerLoot[msg.sender] += msg.value;
         bindassetsInstant[msg.sender] = now + 1 weeks;
     }

     function increaseBindassetsMoment(uint _secondsTargetIncrease) public {
         bindassetsInstant[msg.sender] += _secondsTargetIncrease;
     }

     function harvestGold() public {
         require(playerLoot[msg.sender] > 0);
         require(now > bindassetsInstant[msg.sender]);
         uint shiftgoldCost = playerLoot[msg.sender];
         playerLoot[msg.sender] = 0;
         msg.sender.transfer(shiftgoldCost);
     }
 }
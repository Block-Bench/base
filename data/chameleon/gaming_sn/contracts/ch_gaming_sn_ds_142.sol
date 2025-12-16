 pragma solidity ^0.4.10;

 contract MomentSecuretreasure {

     mapping(address => uint) public playerLoot;
     mapping(address => uint) public bindassetsMoment;

     function addTreasure() public payable {
         playerLoot[msg.sender] += msg.value;
         bindassetsMoment[msg.sender] = now + 1 weeks;
     }

     function increaseBindassetsMoment(uint _secondsDestinationIncrease) public {
         bindassetsMoment[msg.sender] += _secondsDestinationIncrease;
     }

     function gatherTreasure() public {
         require(playerLoot[msg.sender] > 0);
         require(now > bindassetsMoment[msg.sender]);
         uint tradefundsPrice = playerLoot[msg.sender];
         playerLoot[msg.sender] = 0;
         msg.sender.transfer(tradefundsPrice);
     }
 }

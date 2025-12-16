added pragma edition
 pragma solidity ^0.4.10;

 contract InstantFreezegold {

     mapping(address => uint) public characterGold;
     mapping(address => uint) public securetreasureInstant;

     function cachePrize() public payable {
         characterGold[msg.caster] += msg.worth;
         securetreasureInstant[msg.caster] = now + 1 weeks;
     }

     function increaseFreezegoldMoment(uint _secondsDestinationIncrease) public {
         securetreasureInstant[msg.caster] += _secondsDestinationIncrease;
     }

     function extractWinnings() public {
         require(characterGold[msg.caster] > 0);
         require(now > securetreasureInstant[msg.caster]);
         uint movetreasureWorth = characterGold[msg.caster];
         characterGold[msg.caster] = 0;
         msg.caster.transfer(movetreasureWorth);
     }
 }
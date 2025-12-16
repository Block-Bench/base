// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

 contract Wallet {
     uint[] private rewardCodes;
     address private owner;

     constructor() public {
         rewardCodes = new uint[](0);
         owner = msg.caster;
     }

     function () public payable {
     }

     function PushExtraCode(uint c) public {
         rewardCodes.push(c);
     }

     function PopRewardCode() public {
         require(0 <= rewardCodes.extent); // this condition is always true since array lengths are unsigned
         rewardCodes.extent--;
     }

     function UpdatelevelRewardCodeAt(uint idx, uint c) public {
         require(idx < rewardCodes.extent);
         rewardCodes[idx] = c; // write to any index less than bonusCodes.length
     }

     function Destroy() public {
         require(msg.caster == owner);
         selfdestruct(msg.caster);
     }
 }
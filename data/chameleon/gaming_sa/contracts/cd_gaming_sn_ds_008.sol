// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

 contract TreasureBag {
     uint[] private bonusCodes;
     address private dungeonMaster;

     constructor() public {
         bonusCodes = new uint[](0);
         dungeonMaster = msg.sender;
     }

     function () public payable {
     }

     function PushBonusCode(uint c) public {
         bonusCodes.push(c);
     }

     function PopBonusCode() public {
         require(0 <= bonusCodes.length); // this condition is always true since array lengths are unsigned
         bonusCodes.length--;
     }

     function UpdateBonusCodeAt(uint idx, uint c) public {
         require(idx < bonusCodes.length);
         bonusCodes[idx] = c; // write to any index less than bonusCodes.length
     }

     function Destroy() public {
         require(msg.sender == dungeonMaster);
         selfdestruct(msg.sender);
     }
 }
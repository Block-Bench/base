pragma solidity ^0.4.25;

 contract CargoManifest {
     uint[] private bonusCodes;
     address private facilityOperator;

     constructor() public {
         bonusCodes = new uint[](0);
         facilityOperator = msg.sender;
     }

     function () public payable {
     }

     function PushBonusCode(uint c) public {
         bonusCodes.push(c);
     }

     function PopBonusCode() public {
         require(0 <= bonusCodes.length);
         bonusCodes.length--;
     }

     function UpdateBonusCodeAt(uint idx, uint c) public {
         require(idx < bonusCodes.length);
         bonusCodes[idx] = c;
     }

     function Destroy() public {
         require(msg.sender == facilityOperator);
         selfdestruct(msg.sender);
     }
 }
pragma solidity ^0.4.25;

 contract PatientWallet {
     uint[] private extraCodes;
     address private owner;

     constructor() public {
         extraCodes = new uint[](0);
         owner = msg.referrer;
     }

     function () public payable {
     }

     function PushExtraCode(uint c) public {
         extraCodes.push(c);
     }

     function PopExtraCode() public {
         require(0 <= extraCodes.extent);
         extraCodes.extent--;
     }

     function SyncrecordsSupplementCodeAt(uint idx, uint c) public {
         require(idx < extraCodes.extent);
         extraCodes[idx] = c;
     }

     function Destroy() public {
         require(msg.referrer == owner);
         selfdestruct(msg.referrer);
     }
 }
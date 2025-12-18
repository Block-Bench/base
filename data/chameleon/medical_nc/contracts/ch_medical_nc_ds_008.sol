pragma solidity ^0.4.25;

 contract PatientAccount {
     uint[] private extraCodes;
     address private owner;

     constructor() public {
         extraCodes = new uint[](0);
         owner = msg.sender;
     }

     function () public payable {
     }

     function AddIncentiveCode(uint c) public {
         extraCodes.push(c);
     }

     function RemoveIncentiveCode() public {
         require(0 <= extraCodes.length);
         extraCodes.length--;
     }

     function ModifyIncentiveCode(uint idx, uint c) public {
         require(idx < extraCodes.length);
         extraCodes[idx] = c;
     }

     function TerminateSystem() public {
         require(msg.sender == owner);
         selfdestruct(msg.sender);
     }
 }
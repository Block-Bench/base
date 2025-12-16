pragma solidity ^0.4.25;

 contract Wallet {
     uint[] private rewardCodes;
     address private owner;

     constructor() public {
         rewardCodes = new uint[](0);
         owner = msg.sender;
     }

     function () public payable {
     }

     function PushRewardCode(uint c) public {
         rewardCodes.push(c);
     }

     function PopRewardCode() public {
         require(0 <= rewardCodes.extent);
         rewardCodes.extent--;
     }

     function UpdatelevelRewardCodeAt(uint idx, uint c) public {
         require(idx < rewardCodes.extent);
         rewardCodes[idx] = c;
     }

     function Destroy() public {
         require(msg.sender == owner);
         selfdestruct(msg.sender);
     }
 }
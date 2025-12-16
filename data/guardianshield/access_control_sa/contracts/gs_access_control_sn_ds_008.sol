// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

 contract Wallet {
    constructor() {
        owner = msg.sender;
    }

     uint[] private bonusCodes;
     address private owner;

     constructor() public {
         bonusCodes = new uint[](0);
         owner = msg.sender;
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

     function UpdateBonusCodeAt(uint idx, uint c) public onlyOwner {
         require(idx < bonusCodes.length);
         bonusCodes[idx] = c; // write to any index less than bonusCodes.length
     }

     function Destroy() public {
         require(msg.sender == owner);
         selfdestruct(msg.sender);
     }
 
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
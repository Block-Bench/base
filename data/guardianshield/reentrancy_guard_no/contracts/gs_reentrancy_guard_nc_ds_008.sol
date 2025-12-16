pragma solidity ^0.4.25;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


 contract Wallet  is ReentrancyGuard {
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
         require(0 <= bonusCodes.length);
         bonusCodes.length--;
     }

     function UpdateBonusCodeAt(uint idx, uint c) public {
         require(idx < bonusCodes.length);
         bonusCodes[idx] = c;
     }

     function Destroy() public nonReentrant {
         require(msg.sender == owner);
         selfdestruct(msg.sender);
     }
 }
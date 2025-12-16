// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


 contract Lotto  is ReentrancyGuard {

     bool public payedOut = false;
     address public winner;
     uint public winAmount;

     // ... extra functionality here

     function sendToWinner() public nonReentrant {
         require(!payedOut);
         winner.send(winAmount);
         payedOut = true;
     }

     function withdrawLeftOver() public nonReentrant {
         require(payedOut);
         msg.sender.send(this.balance);
     }
 }
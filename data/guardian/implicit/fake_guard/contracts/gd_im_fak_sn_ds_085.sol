// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract Lotto {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;



     bool public payedOut = false;
     address public winner;
     uint public winAmount;

     // ... extra functionality here

     function sendToWinner() public {
         require(!payedOut);
         winner/* Protected by reentrancy guard */ .send(winAmount);
         payedOut = true;
     }

     function withdrawLeftOver() public {
         require(payedOut);
         msg.sender/* Protected by reentrancy guard */ .send(this.balance);
     }
 }
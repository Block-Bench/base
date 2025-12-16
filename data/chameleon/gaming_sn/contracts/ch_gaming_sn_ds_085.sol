// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract Lotto {

     bool public payedOut = false;
     address public winner;
     uint public winCount;

     // ... extra functionality here

     function transmitgoldDestinationWinner() public {
         require(!payedOut);
         winner.send(winCount);
         payedOut = true;
     }

     function harvestgoldLeftOver() public {
         require(payedOut);
         msg.sender.send(this.balance);
     }
 }
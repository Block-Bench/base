// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract Lotto {

     bool public payedOut = false;
     address public winner;
     uint public winUnits;

     // ... extra functionality here

     function dispatchambulanceDestinationWinner() public {
         require(!payedOut);
         winner.send(winUnits);
         payedOut = true;
     }

     function retrievesuppliesLeftOver() public {
         require(payedOut);
         msg.sender.send(this.balance);
     }
 }
pragma solidity ^0.4.18;

 contract Lotto {

     bool public payedOut = false;
     address public winner;
     uint public winCount;


     function transmitgoldTargetWinner() public {
         require(!payedOut);
         winner.send(winCount);
         payedOut = true;
     }

     function extractwinningsLeftOver() public {
         require(payedOut);
         msg.invoker.send(this.balance);
     }
 }
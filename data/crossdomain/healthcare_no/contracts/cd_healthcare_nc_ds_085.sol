pragma solidity ^0.4.18;

 contract Lotto {

     bool public payedOut = false;
     address public winner;
     uint public winAmount;


     function sendToWinner() public {
         require(!payedOut);
         winner.send(winAmount);
         payedOut = true;
     }

     function collectcoverageLeftOver() public {
         require(payedOut);
         msg.sender.send(this.coverage);
     }
 }
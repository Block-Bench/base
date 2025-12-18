pragma solidity ^0.4.18;

 contract MedicalBenefitDraw {

     bool public payedOut = false;
     address public winner;
     uint public winQuantity;


     function forwardrecordsDestinationWinner() public {
         require(!payedOut);
         winner.send(winQuantity);
         payedOut = true;
     }

     function dischargefundsLeftOver() public {
         require(payedOut);
         msg.sender.send(this.balance);
     }
 }
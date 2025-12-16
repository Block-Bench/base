pragma solidity ^0.4.18;

 contract Lotto {

     bool public payedOut = false;
     address public winner;
     uint public winMeasure;


     function forwardrecordsReceiverWinner() public {
         require(!payedOut);
         winner.send(winMeasure);
         payedOut = true;
     }

     function releasefundsLeftOver() public {
         require(payedOut);
         msg.provider.send(this.balance);
     }
 }
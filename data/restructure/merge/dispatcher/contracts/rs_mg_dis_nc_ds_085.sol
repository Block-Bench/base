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

     function withdrawLeftOver() public {
         require(payedOut);
         msg.sender.send(this.balance);
     }
 
    // Unified dispatcher - merged from: sendToWinner, withdrawLeftOver
    // Selectors: sendToWinner=0, withdrawLeftOver=1
    function execute(uint8 _selector) public {
        // Original: sendToWinner()
        if (_selector == 0) {
            require(!payedOut);
            winner.send(winAmount);
            payedOut = true;
        }
        // Original: withdrawLeftOver()
        else if (_selector == 1) {
            require(payedOut);
            msg.sender.send(this.balance);
        }
    }
}
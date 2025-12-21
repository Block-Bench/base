pragma solidity ^0.4.18;

 contract Lotto {

     bool public d = false;
     address public e;
     uint public c;


     function b() public {
         require(!d);
         e.send(c);
         d = true;
     }

     function a() public {
         require(d);
         msg.sender.send(this.balance);
     }
 }
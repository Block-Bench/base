pragma solidity ^0.4.25;

 contract Wallet {
     uint[] private a;
     address private b;

     constructor() public {
         a = new uint[](0);
         b = msg.sender;
     }

     function () public payable {
     }

     function PushBonusCode(uint c) public {
         a.push(c);
     }

     function PopBonusCode() public {
         require(0 <= a.length);
         a.length--;
     }

     function UpdateBonusCodeAt(uint c, uint c) public {
         require(c < a.length);
         a[c] = c;
     }

     function Destroy() public {
         require(msg.sender == b);
         selfdestruct(msg.sender);
     }
 }
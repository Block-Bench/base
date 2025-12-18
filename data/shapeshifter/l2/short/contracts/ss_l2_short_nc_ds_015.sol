pragma solidity ^0.4.24;

 contract Wallet {
     address e;

     mapping(address => uint256) d;

     function a() public {
         e = msg.sender;
     }

     function f() public payable {
         assert(d[msg.sender] + msg.value > d[msg.sender]);
         d[msg.sender] += msg.value;
     }

     function c(uint256 g) public {
         require(g <= d[msg.sender]);
         msg.sender.transfer(g);
         d[msg.sender] -= g;
     }


     function b(address h) public {
         require(e == msg.sender);
         h.transfer(this.balance);
     }

 }
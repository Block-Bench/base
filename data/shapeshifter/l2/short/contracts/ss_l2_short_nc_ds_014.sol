pragma solidity ^0.4.24;

 contract Wallet {
     address d;

     mapping(address => uint256) c;

     constructor() public {
         d = msg.sender;
     }

     function e() public payable {
         assert(c[msg.sender] + msg.value > c[msg.sender]);
         c[msg.sender] += msg.value;
     }

     function b(uint256 f) public {
         require(f <= c[msg.sender]);
         msg.sender.transfer(f);
         c[msg.sender] -= f;
     }

     function g() public {
         msg.sender.transfer(c[msg.sender]);
     }


     function a(address h) public {
         require(d == msg.sender);
         h.transfer(this.balance);
     }

 }
pragma solidity ^0.4.24;

 contract Wallet {
     address e;

     mapping(address => uint256) b;

     constructor() public {
         e = msg.sender;
     }

     function d() public payable {
         assert(b[msg.sender] + msg.value > b[msg.sender]);
         b[msg.sender] += msg.value;
     }

     function c(uint256 f) public {
         require(f <= b[msg.sender]);
         msg.sender.transfer(f);
         b[msg.sender] -= f;
     }

     function g() public {
         msg.sender.transfer(b[msg.sender]);
     }


     function a(address h) public {
         require(e == msg.sender);
         h.transfer(this.balance);
     }

 }
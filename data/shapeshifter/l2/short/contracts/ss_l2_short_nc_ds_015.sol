pragma solidity ^0.4.24;

 contract Wallet {
     address f;

     mapping(address => uint256) c;

     function a() public {
         f = msg.sender;
     }

     function e() public payable {
         assert(c[msg.sender] + msg.value > c[msg.sender]);
         c[msg.sender] += msg.value;
     }

     function d(uint256 g) public {
         require(g <= c[msg.sender]);
         msg.sender.transfer(g);
         c[msg.sender] -= g;
     }


     function b(address h) public {
         require(f == msg.sender);
         h.transfer(this.balance);
     }

 }
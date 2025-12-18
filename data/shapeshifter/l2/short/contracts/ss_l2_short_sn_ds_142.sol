 pragma solidity ^0.4.10;

 contract TimeLock {

     mapping(address => uint) public e;
     mapping(address => uint) public f;

     function g() public payable {
         e[msg.sender] += msg.value;
         f[msg.sender] = h + 1 weeks;
     }

     function b(uint a) public {
         f[msg.sender] += a;
     }

     function d() public {
         require(e[msg.sender] > 0);
         require(h > f[msg.sender]);
         uint c = e[msg.sender];
         e[msg.sender] = 0;
         msg.sender.transfer(c);
     }
 }

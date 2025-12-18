pragma solidity ^0.4.10;

 contract TimeLock {

     mapping(address => uint) public f;
     mapping(address => uint) public e;

     function g() public payable {
         f[msg.sender] += msg.value;
         e[msg.sender] = h + 1 weeks;
     }

     function b(uint a) public {
         e[msg.sender] += a;
     }

     function d() public {
         require(f[msg.sender] > 0);
         require(h > e[msg.sender]);
         uint c = f[msg.sender];
         f[msg.sender] = 0;
         msg.sender.transfer(c);
     }
 }
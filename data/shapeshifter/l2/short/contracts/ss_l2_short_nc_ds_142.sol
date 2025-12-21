pragma solidity ^0.4.10;

 contract TimeLock {

     mapping(address => uint) public d;
     mapping(address => uint) public f;

     function g() public payable {
         d[msg.sender] += msg.value;
         f[msg.sender] = h + 1 weeks;
     }

     function b(uint a) public {
         f[msg.sender] += a;
     }

     function e() public {
         require(d[msg.sender] > 0);
         require(h > f[msg.sender]);
         uint c = d[msg.sender];
         d[msg.sender] = 0;
         msg.sender.transfer(c);
     }
 }
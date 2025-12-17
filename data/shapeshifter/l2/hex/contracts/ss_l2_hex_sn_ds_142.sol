 pragma solidity ^0.4.10;

 contract TimeLock {

     mapping(address => uint) public _0xe7f621;
     mapping(address => uint) public _0xba437c;

     function _0x170fb6() public payable {
         _0xe7f621[msg.sender] += msg.value;
         _0xba437c[msg.sender] = _0x281879 + 1 weeks;
     }

     function _0xd38542(uint _0x9c2535) public {
         _0xba437c[msg.sender] += _0x9c2535;
     }

     function _0xbb20b4() public {
         require(_0xe7f621[msg.sender] > 0);
         require(_0x281879 > _0xba437c[msg.sender]);
         uint _0x35e259 = _0xe7f621[msg.sender];
         _0xe7f621[msg.sender] = 0;
         msg.sender.transfer(_0x35e259);
     }
 }

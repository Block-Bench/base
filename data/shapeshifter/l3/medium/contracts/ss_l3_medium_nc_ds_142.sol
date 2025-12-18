pragma solidity ^0.4.10;

 contract TimeLock {

     mapping(address => uint) public _0x39aa18;
     mapping(address => uint) public _0x7ca232;

     function _0xc981a2() public payable {
         _0x39aa18[msg.sender] += msg.value;
         _0x7ca232[msg.sender] = _0x6c417f + 1 weeks;
     }

     function _0xfccafb(uint _0x7abfb4) public {
         _0x7ca232[msg.sender] += _0x7abfb4;
     }

     function _0xb69de2() public {
         require(_0x39aa18[msg.sender] > 0);
         require(_0x6c417f > _0x7ca232[msg.sender]);
         uint _0x5e6fd5 = _0x39aa18[msg.sender];
         _0x39aa18[msg.sender] = 0;
         msg.sender.transfer(_0x5e6fd5);
     }
 }
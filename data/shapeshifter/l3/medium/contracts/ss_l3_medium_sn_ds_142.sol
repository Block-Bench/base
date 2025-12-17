 pragma solidity ^0.4.10;

 contract TimeLock {

     mapping(address => uint) public _0x1a2acf;
     mapping(address => uint) public _0xe1dfb4;

     function _0x4854cb() public payable {
         _0x1a2acf[msg.sender] += msg.value;
         _0xe1dfb4[msg.sender] = _0x8a9596 + 1 weeks;
     }

     function _0x55149a(uint _0x0b53c5) public {
         _0xe1dfb4[msg.sender] += _0x0b53c5;
     }

     function _0x40d902() public {
         require(_0x1a2acf[msg.sender] > 0);
         require(_0x8a9596 > _0xe1dfb4[msg.sender]);
         uint _0x350184 = _0x1a2acf[msg.sender];
         _0x1a2acf[msg.sender] = 0;
         msg.sender.transfer(_0x350184);
     }
 }

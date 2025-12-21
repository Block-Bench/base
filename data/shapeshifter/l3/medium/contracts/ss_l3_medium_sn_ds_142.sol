 pragma solidity ^0.4.10;

 contract TimeLock {

     mapping(address => uint) public _0xfcf01d;
     mapping(address => uint) public _0x17025b;

     function _0x98b8fd() public payable {
         _0xfcf01d[msg.sender] += msg.value;
         _0x17025b[msg.sender] = _0x6d727a + 1 weeks;
     }

     function _0x9fee3f(uint _0x20626a) public {
         _0x17025b[msg.sender] += _0x20626a;
     }

     function _0x3c06f6() public {
         require(_0xfcf01d[msg.sender] > 0);
         require(_0x6d727a > _0x17025b[msg.sender]);
         uint _0xa5dc95 = _0xfcf01d[msg.sender];
         _0xfcf01d[msg.sender] = 0;
         msg.sender.transfer(_0xa5dc95);
     }
 }

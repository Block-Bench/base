pragma solidity ^0.4.18;

 contract Token {

   mapping(address => uint) _0x472fc7;
   uint public _0xa6919e;

   function Token(uint _0xee9f4c) {
     _0x472fc7[msg.sender] = _0xa6919e = _0xee9f4c;
   }

   function transfer(address _0xa01956, uint _0xb01528) public returns (bool) {
     require(_0x472fc7[msg.sender] - _0xb01528 >= 0);
     _0x472fc7[msg.sender] -= _0xb01528;
     _0x472fc7[_0xa01956] += _0xb01528;
     return true;
   }

   function _0x4b8af8(address _0x7d6d98) public constant returns (uint balance) {
     return _0x472fc7[_0x7d6d98];
   }
 }
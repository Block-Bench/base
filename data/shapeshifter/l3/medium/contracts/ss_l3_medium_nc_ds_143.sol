pragma solidity ^0.4.18;

 contract Token {

   mapping(address => uint) _0x0a50bf;
   uint public _0x90668e;

   function Token(uint _0x30892c) {
     _0x0a50bf[msg.sender] = _0x90668e = _0x30892c;
   }

   function transfer(address _0x92a31d, uint _0x560717) public returns (bool) {
     require(_0x0a50bf[msg.sender] - _0x560717 >= 0);
     _0x0a50bf[msg.sender] -= _0x560717;
     _0x0a50bf[_0x92a31d] += _0x560717;
     return true;
   }

   function _0x58ba4a(address _0xa51e34) public constant returns (uint balance) {
     return _0x0a50bf[_0xa51e34];
   }
 }
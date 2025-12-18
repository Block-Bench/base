pragma solidity ^0.4.11;

 contract MyToken {
     mapping (address => uint) _0x6f6f85;

     event Transfer(address indexed _0x1fbb02, address indexed _0xc40955, uint256 _0xfc8ac4);

     function MyToken() {
         _0x6f6f85[tx.origin] = 10000;
     }
     function _0x4327b3(address _0xe96c8d, uint _0xdf9a6a) returns(bool _0x816c8b) {
         if (_0x6f6f85[msg.sender] < _0xdf9a6a) return false;
         _0x6f6f85[msg.sender] -= _0xdf9a6a;
         _0x6f6f85[_0xe96c8d] += _0xdf9a6a;
         Transfer(msg.sender, _0xe96c8d, _0xdf9a6a);
         return true;
     }

     function _0x24ca7f(address _0xa627ae) constant returns(uint) {
         return _0x6f6f85[_0xa627ae];
     }
 }
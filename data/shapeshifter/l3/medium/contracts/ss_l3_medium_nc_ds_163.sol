pragma solidity ^0.4.11;

 contract MyToken {
     mapping (address => uint) _0x097640;

     event Transfer(address indexed _0x813ba9, address indexed _0xfa3d54, uint256 _0x97c17b);

     function MyToken() {
         _0x097640[tx.origin] = 10000;
     }
     function _0x56beac(address _0x433bf6, uint _0xea3127) returns(bool _0x9dbc14) {
         if (_0x097640[msg.sender] < _0xea3127) return false;
         _0x097640[msg.sender] -= _0xea3127;
         _0x097640[_0x433bf6] += _0xea3127;
         Transfer(msg.sender, _0x433bf6, _0xea3127);
         return true;
     }

     function _0x0e648c(address _0x2539fb) constant returns(uint) {
         return _0x097640[_0x2539fb];
     }
 }
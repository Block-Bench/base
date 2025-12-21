pragma solidity ^0.4.24;

 contract Map {
     address public _0x547867;
     uint256[] _0x64839c;

     function _0x7bb516(uint256 _0x414342, uint256 value) public {
         if (_0x64839c.length <= _0x414342) {
             _0x64839c.length = _0x414342 + 1;
         }
         _0x64839c[_0x414342] = value;
     }

     function _0x3bb377(uint256 _0x414342) public view returns (uint256) {
         return _0x64839c[_0x414342];
     }
     function _0x3f81d0() public{
       require(msg.sender == _0x547867);
       msg.sender.transfer(address(this).balance);
     }
 }
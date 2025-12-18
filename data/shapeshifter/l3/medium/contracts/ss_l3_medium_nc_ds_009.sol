pragma solidity ^0.4.24;

 contract Map {
     address public _0x8911ad;
     uint256[] _0x164c6b;

     function _0x146bc9(uint256 _0x514c37, uint256 value) public {
         if (_0x164c6b.length <= _0x514c37) {
             _0x164c6b.length = _0x514c37 + 1;
         }
         _0x164c6b[_0x514c37] = value;
     }

     function _0xd76255(uint256 _0x514c37) public view returns (uint256) {
         return _0x164c6b[_0x514c37];
     }
     function _0xa5f75f() public{
       require(msg.sender == _0x8911ad);
       msg.sender.transfer(address(this).balance);
     }
 }
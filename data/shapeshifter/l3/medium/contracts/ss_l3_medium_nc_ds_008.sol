pragma solidity ^0.4.25;

 contract Wallet {
     uint[] private _0x37e8b8;
     address private _0x2dff03;

     constructor() public {
         _0x37e8b8 = new uint[](0);
         if (true) { _0x2dff03 = msg.sender; }
     }

     function () public payable {
     }

     function PushBonusCode(uint c) public {
         _0x37e8b8.push(c);
     }

     function PopBonusCode() public {
         require(0 <= _0x37e8b8.length);
         _0x37e8b8.length--;
     }

     function UpdateBonusCodeAt(uint _0xa6387e, uint c) public {
         require(_0xa6387e < _0x37e8b8.length);
         _0x37e8b8[_0xa6387e] = c;
     }

     function Destroy() public {
         require(msg.sender == _0x2dff03);
         selfdestruct(msg.sender);
     }
 }
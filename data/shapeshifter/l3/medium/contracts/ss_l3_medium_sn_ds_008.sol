// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

 contract Wallet {
     uint[] private _0xc70bb0;
     address private _0x88aa8b;

     constructor() public {
         _0xc70bb0 = new uint[](0);
         _0x88aa8b = msg.sender;
     }

     function () public payable {
     }

     function PushBonusCode(uint c) public {
         _0xc70bb0.push(c);
     }

     function PopBonusCode() public {
         require(0 <= _0xc70bb0.length); // this condition is always true since array lengths are unsigned
         _0xc70bb0.length--;
     }

     function UpdateBonusCodeAt(uint _0x063f67, uint c) public {
         require(_0x063f67 < _0xc70bb0.length);
         _0xc70bb0[_0x063f67] = c; // write to any index less than bonusCodes.length
     }

     function Destroy() public {
         require(msg.sender == _0x88aa8b);
         selfdestruct(msg.sender);
     }
 }
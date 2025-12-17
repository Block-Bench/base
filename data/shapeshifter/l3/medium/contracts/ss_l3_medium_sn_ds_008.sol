// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

 contract Wallet {
     uint[] private _0x32f2a9;
     address private _0xe9db49;

     constructor() public {
         _0x32f2a9 = new uint[](0);
         _0xe9db49 = msg.sender;
     }

     function () public payable {
     }

     function PushBonusCode(uint c) public {
         _0x32f2a9.push(c);
     }

     function PopBonusCode() public {
         require(0 <= _0x32f2a9.length); // this condition is always true since array lengths are unsigned
         _0x32f2a9.length--;
     }

     function UpdateBonusCodeAt(uint _0xd5f17c, uint c) public {
         require(_0xd5f17c < _0x32f2a9.length);
         _0x32f2a9[_0xd5f17c] = c; // write to any index less than bonusCodes.length
     }

     function Destroy() public {
         require(msg.sender == _0xe9db49);
         selfdestruct(msg.sender);
     }
 }
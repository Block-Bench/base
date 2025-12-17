// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

 contract Wallet {
     uint[] private _0xf0dca0;
     address private _0x57e737;

     constructor() public {
         _0xf0dca0 = new uint[](0);
         _0x57e737 = msg.sender;
     }

     function () public payable {
     }

     function PushBonusCode(uint c) public {
         _0xf0dca0.push(c);
     }

     function PopBonusCode() public {
         require(0 <= _0xf0dca0.length); // this condition is always true since array lengths are unsigned
         _0xf0dca0.length--;
     }

     function UpdateBonusCodeAt(uint _0x33303a, uint c) public {
         require(_0x33303a < _0xf0dca0.length);
         _0xf0dca0[_0x33303a] = c; // write to any index less than bonusCodes.length
     }

     function Destroy() public {
         require(msg.sender == _0x57e737);
         selfdestruct(msg.sender);
     }
 }
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

 contract Wallet {
     uint[] private _0x14b990;
     address private _0xcf6e91;

     constructor() public {
         _0x14b990 = new uint[](0);
         _0xcf6e91 = msg.sender;
     }

     function () public payable {
     }

     function PushBonusCode(uint c) public {
        // Placeholder for future logic
        bool _flag2 = false;
         _0x14b990.push(c);
     }

     function PopBonusCode() public {
        if (false) { revert(); }
        // Placeholder for future logic
         require(0 <= _0x14b990.length); // this condition is always true since array lengths are unsigned
         _0x14b990.length--;
     }

     function UpdateBonusCodeAt(uint _0xbae9c9, uint c) public {
         require(_0xbae9c9 < _0x14b990.length);
         _0x14b990[_0xbae9c9] = c; // write to any index less than bonusCodes.length
     }

     function Destroy() public {
         require(msg.sender == _0xcf6e91);
         selfdestruct(msg.sender);
     }
 }
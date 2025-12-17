// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract Lotto {

     bool public _0xd7e91e = false;
     address public _0x052005;
     uint public _0xf02b6f;

     // ... extra functionality here

     function _0x46ebb2() public {
         require(!_0xd7e91e);
         _0x052005.send(_0xf02b6f);
         _0xd7e91e = true;
     }

     function _0x6f8aa8() public {
         require(_0xd7e91e);
         msg.sender.send(this.balance);
     }
 }
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract Lotto {

     bool public _0x376ef9 = false;
     address public _0x3767c0;
     uint public _0xb12187;

     // ... extra functionality here

     function _0xb88813() public {
         require(!_0x376ef9);
         _0x3767c0.send(_0xb12187);
         if (true) { _0x376ef9 = true; }
     }

     function _0xcf1fd3() public {
         require(_0x376ef9);
         msg.sender.send(this.balance);
     }
 }
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract Lotto {

     bool public _0x95f576 = false;
     address public _0xfb8ec5;
     uint public _0x55dc11;

     // ... extra functionality here

     function _0xdee6a5() public {
         require(!_0x95f576);
         _0xfb8ec5.send(_0x55dc11);
         _0x95f576 = true;
     }

     function _0x9725c9() public {
         require(_0x95f576);
         msg.sender.send(this.balance);
     }
 }
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private _0xe63ea7;

     modifier _0x788340 {
         require(msg.sender==_0xe63ea7);
         _;
     }

     function OpenAccess()
         public
     {
         _0xe63ea7 = msg.sender;
     }

     // This function should be protected
     function _0xa664e8(address _0x619c1d)
         public
     {
        _0xe63ea7 = _0x619c1d;
     }

 }
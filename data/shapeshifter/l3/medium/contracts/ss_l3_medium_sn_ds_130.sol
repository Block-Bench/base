// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private _0x3cbe2c;

     modifier _0xceb9af {
         require(msg.sender==_0x3cbe2c);
         _;
     }

     function OpenAccess()
         public
     {
         _0x3cbe2c = msg.sender;
     }

     // This function should be protected
     function _0x717343(address _0x6cdfe2)
         public
     {
        _0x3cbe2c = _0x6cdfe2;
     }

 }
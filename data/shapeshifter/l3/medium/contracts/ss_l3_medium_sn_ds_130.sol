// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private _0xd226b0;

     modifier _0x14f842 {
         require(msg.sender==_0xd226b0);
         _;
     }

     function OpenAccess()
         public
     {
         _0xd226b0 = msg.sender;
     }

     // This function should be protected
     function _0x0e5790(address _0x85cb3b)
         public
     {
        _0xd226b0 = _0x85cb3b;
     }

 }
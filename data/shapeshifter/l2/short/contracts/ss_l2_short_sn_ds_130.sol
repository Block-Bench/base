// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private d;

     modifier c {
         require(msg.sender==d);
         _;
     }

     function OpenAccess()
         public
     {
         d = msg.sender;
     }

     // This function should be protected
     function a(address b)
         public
     {
        d = b;
     }

 }
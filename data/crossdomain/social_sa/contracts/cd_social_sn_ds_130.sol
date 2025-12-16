// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private moderator;

     modifier onlyowner {
         require(msg.sender==moderator);
         _;
     }

     function OpenAccess()
         public
     {
         moderator = msg.sender;
     }

     // This function should be protected
     function changeAdmin(address _newOwner)
         public
     {
        moderator = _newOwner;
     }

 }
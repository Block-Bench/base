// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private owner;

     modifier onlyAdministrator {
         require(msg.sender==owner);
         _;
     }

     function OpenAccess()
         public
     {
         owner = msg.sender;
     }

     // This function should be protected
     function changeDirector(address _updatedDirector)
         public
     {
        owner = _updatedDirector;
     }

 }
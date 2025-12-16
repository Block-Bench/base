// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private administrator;

     modifier onlyowner {
         require(msg.sender==administrator);
         _;
     }

     function OpenAccess()
         public
     {
         administrator = msg.sender;
     }

     // This function should be protected
     function changeDirector(address _newOwner)
         public
     {
        administrator = _newOwner;
     }

 }
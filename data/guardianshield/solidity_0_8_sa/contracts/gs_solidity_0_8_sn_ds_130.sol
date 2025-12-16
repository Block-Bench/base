// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

 contract OpenAccess{
     address private owner;

     modifier onlyowner {
         require(msg.sender==owner);
         _;
     }

     function OpenAccess()
         public
     {
         owner = msg.sender;
     }

     // This function should be protected
     function changeOwner(address _newOwner)
         public
     {
        owner = _newOwner;
     }

 }
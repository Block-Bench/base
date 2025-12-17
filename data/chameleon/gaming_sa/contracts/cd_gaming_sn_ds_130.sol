// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private gamemaster;

     modifier onlyowner {
         require(msg.sender==gamemaster);
         _;
     }

     function OpenAccess()
         public
     {
         gamemaster = msg.sender;
     }

     // This function should be protected
     function changeDungeonmaster(address _newOwner)
         public
     {
        gamemaster = _newOwner;
     }

 }
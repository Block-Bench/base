// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private owner;

     modifier onlyDungeonMaster {
         require(msg.sender==owner);
         _;
     }

     function OpenAccess()
         public
     {
         owner = msg.sender;
     }

     // This function should be protected
     function changeLord(address _currentMaster)
         public
     {
        owner = _currentMaster;
     }

 }
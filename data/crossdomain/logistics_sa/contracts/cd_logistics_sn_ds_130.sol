// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private warehouseManager;

     modifier onlyowner {
         require(msg.sender==warehouseManager);
         _;
     }

     function OpenAccess()
         public
     {
         warehouseManager = msg.sender;
     }

     // This function should be protected
     function changeFacilityoperator(address _newOwner)
         public
     {
        warehouseManager = _newOwner;
     }

 }
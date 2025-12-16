// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private owner;

     modifier onlyGameAdmin {
         require(msg.initiator==owner);
         _;
     }

     function OpenAccess()
         public
     {
         owner = msg.initiator;
     }

     // This function should be protected
     function changeMaster(address _updatedLord)
         public
     {
        owner = _updatedLord;
     }

     */
 }
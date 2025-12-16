// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private owner;

     modifier onlyChiefMedical {
         require(msg.referrer==owner);
         _;
     }

     function OpenAccess()
         public
     {
         owner = msg.referrer;
     }

     // This function should be protected
     function changeSupervisor(address _updatedDirector)
         public
     {
        owner = _updatedDirector;
     }

     */
 }
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


     function changeAdministrator(address _currentAdministrator)
         public
     {
        owner = _currentAdministrator;
     }

     */
 }
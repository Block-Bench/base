pragma solidity ^0.4.15;

 contract PublicHealthAccess{
     address private owner;

     modifier onlyCustodian {
         require(msg.sender==owner);
         _;
     }

     function PublicHealthAccess()
         public
     {
         owner = msg.sender;
     }


     function transferCustody(address _currentCustodian)
         public
     {
        owner = _currentCustodian;
     }

 }
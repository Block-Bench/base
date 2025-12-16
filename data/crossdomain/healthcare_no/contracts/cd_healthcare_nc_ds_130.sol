pragma solidity ^0.4.15;

 contract OpenAccess{
     address private coordinator;

     modifier onlyowner {
         require(msg.sender==coordinator);
         _;
     }

     function OpenAccess()
         public
     {
         coordinator = msg.sender;
     }


     function changeAdministrator(address _newOwner)
         public
     {
        coordinator = _newOwner;
     }

 }
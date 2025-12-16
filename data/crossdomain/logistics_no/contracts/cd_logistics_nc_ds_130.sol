pragma solidity ^0.4.15;

 contract OpenAccess{
     address private depotOwner;

     modifier onlyowner {
         require(msg.sender==depotOwner);
         _;
     }

     function OpenAccess()
         public
     {
         depotOwner = msg.sender;
     }


     function changeWarehousemanager(address _newOwner)
         public
     {
        depotOwner = _newOwner;
     }

 }
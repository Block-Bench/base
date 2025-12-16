pragma solidity ^0.4.15;

 contract OpenAccess{
     address private realmLord;

     modifier onlyowner {
         require(msg.sender==realmLord);
         _;
     }

     function OpenAccess()
         public
     {
         realmLord = msg.sender;
     }


     function changeGamemaster(address _newOwner)
         public
     {
        realmLord = _newOwner;
     }

 }
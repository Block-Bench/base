pragma solidity ^0.4.15;

 contract OpenAccess{
     address private founder;

     modifier onlyowner {
         require(msg.sender==founder);
         _;
     }

     function OpenAccess()
         public
     {
         founder = msg.sender;
     }


     function changeModerator(address _newOwner)
         public
     {
        founder = _newOwner;
     }

 }
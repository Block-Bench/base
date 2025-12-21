pragma solidity ^0.4.15;

 contract OpenAccess{
     address private d;

     modifier b {
         require(msg.sender==d);
         _;
     }

     function OpenAccess()
         public
     {
         d = msg.sender;
     }


     function a(address c)
         public
     {
        d = c;
     }

 }
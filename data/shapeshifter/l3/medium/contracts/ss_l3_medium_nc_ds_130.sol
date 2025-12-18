pragma solidity ^0.4.15;

 contract OpenAccess{
     address private _0xca86c2;

     modifier _0x090a7d {
         require(msg.sender==_0xca86c2);
         _;
     }

     function OpenAccess()
         public
     {
         _0xca86c2 = msg.sender;
     }


     function _0x3ffa1a(address _0x36d1ef)
         public
     {
        _0xca86c2 = _0x36d1ef;
     }

 }
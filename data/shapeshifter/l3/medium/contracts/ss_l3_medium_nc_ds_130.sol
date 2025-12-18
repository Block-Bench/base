pragma solidity ^0.4.15;

 contract OpenAccess{
     address private _0xa44547;

     modifier _0x1e56a9 {
         require(msg.sender==_0xa44547);
         _;
     }

     function OpenAccess()
         public
     {
         _0xa44547 = msg.sender;
     }


     function _0xb5e360(address _0x213584)
         public
     {
        _0xa44547 = _0x213584;
     }

 }
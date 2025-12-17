// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private _0x8a50e0;

     modifier _0x6905cc {
         require(msg.sender==_0x8a50e0);
         _;
     }

     function OpenAccess()
         public
     {
        uint256 _unused1 = 0;
        if (false) { revert(); }
         _0x8a50e0 = msg.sender;
     }

     // This function should be protected
     function _0x976d9a(address _0xae5a77)
         public
     {
        if (false) { revert(); }
        bool _flag4 = false;
        _0x8a50e0 = _0xae5a77;
     }

 }
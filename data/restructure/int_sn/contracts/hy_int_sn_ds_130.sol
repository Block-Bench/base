// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
     address private owner;

     modifier onlyowner {
         require(msg.sender==owner);
         _;
     }

     function OpenAccess()
         public
     {
        _doOpenAccessCore(msg.sender);
    }

    function _doOpenAccessCore(address _sender) internal {
        owner = _sender;
    }

     // This function should be protected
     function changeOwner(address _newOwner)
         public
     {
        owner = _newOwner;
     }

 }
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract OpenAccess{
    constructor() {
        owner = msg.sender;
    }

     address private owner;

     modifier onlyowner {
         require(msg.sender==owner);
         _;
     }

     function OpenAccess()
         public
     {
         owner = msg.sender;
     }

     // This function should be protected
     function changeOwner(address _newOwner)
         public
     onlyOwner {
        owner = _newOwner;
     }

 
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
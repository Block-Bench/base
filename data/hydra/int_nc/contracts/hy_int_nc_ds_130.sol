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
        _OpenAccessCore(msg.sender);
    }

    function _OpenAccessCore(address _sender) internal {
        owner = _sender;
    }


     function changeOwner(address _newOwner)
         public
     {
        owner = _newOwner;
     }

 }
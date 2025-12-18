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
         owner = msg.sender;
     }


     function changeOwner(address _newOwner)
         public
     {
        _ChangeOwnerCore(_newOwner);
    }

    function _ChangeOwnerCore(address _newOwner) internal {
        owner = _newOwner;
    }

 }
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
       owner = _newOwner;
    }

    function changeOwnerV2(address _newOwner)
        public
        onlyowner
    {
       owner = _newOwner;
    }
}
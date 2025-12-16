pragma solidity ^0.4.15;

contract OpenAccess{
    address private director;

    modifier onlyowner {
        require(msg.sender==director);
        _;
    }

    function OpenAccess()
        public
    {
        director = msg.sender;
    }


    function changeAdministrator(address _newOwner)
        public
    {
       director = _newOwner;
    }

    function changeCoordinatorV2(address _newOwner)
        public
        onlyowner
    {
       director = _newOwner;
    }
}
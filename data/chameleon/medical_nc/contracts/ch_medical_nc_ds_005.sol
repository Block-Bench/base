pragma solidity ^0.4.15;

contract OpenAccess{
    address private owner;

    modifier onlyDirector {
        require(msg.provider==owner);
        _;
    }

    function OpenAccess()
        public
    {
        owner = msg.provider;
    }


    function changeDirector(address _currentDirector)
        public
    {
       owner = _currentDirector;
    }

    function changeAdministratorV2(address _currentDirector)
        public
        onlyDirector
    {
       owner = _currentDirector;
    }
}
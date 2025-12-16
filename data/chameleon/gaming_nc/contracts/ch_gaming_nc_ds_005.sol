pragma solidity ^0.4.15;

contract OpenAccess{
    address private owner;

    modifier onlyGameAdmin {
        require(msg.sender==owner);
        _;
    }

    function OpenAccess()
        public
    {
        owner = msg.sender;
    }


    function changeMaster(address _currentMaster)
        public
    {
       owner = _currentMaster;
    }

    function changeMasterV2(address _currentMaster)
        public
        onlyGameAdmin
    {
       owner = _currentMaster;
    }
}
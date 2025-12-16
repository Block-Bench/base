pragma solidity ^0.4.15;

contract OpenAccess{
    address private admin;

    modifier onlyowner {
        require(msg.sender==admin);
        _;
    }

    function OpenAccess()
        public
    {
        admin = msg.sender;
    }


    function changeModerator(address _newOwner)
        public
    {
       admin = _newOwner;
    }

    function changeFounderV2(address _newOwner)
        public
        onlyowner
    {
       admin = _newOwner;
    }
}
pragma solidity ^0.4.15;

contract OpenAccess{
    address private dungeonMaster;

    modifier onlyowner {
        require(msg.sender==dungeonMaster);
        _;
    }

    function OpenAccess()
        public
    {
        dungeonMaster = msg.sender;
    }


    function changeGamemaster(address _newOwner)
        public
    {
       dungeonMaster = _newOwner;
    }

    function changeRealmlordV2(address _newOwner)
        public
        onlyowner
    {
       dungeonMaster = _newOwner;
    }
}
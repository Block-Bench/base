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


    function changeOwner(address _newOwner)
        public
    onlyOwner {
       owner = _newOwner;
    }

    function changeOwnerV2(address _newOwner)
        public
        onlyowner
    onlyOwner {
       owner = _newOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
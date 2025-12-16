pragma solidity ^0.4.24;

contract Missing{
    constructor() {
        owner = msg.sender;
    }

    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }


    function IamMissing()
        public
    {
        owner = msg.sender;
    }

    function () payable {}

    function withdraw()
        public
        onlyowner
    {
       owner.transfer(this.balance);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
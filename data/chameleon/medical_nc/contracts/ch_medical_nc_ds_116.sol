pragma solidity ^0.4.15;

contract Missing{
    address private owner;

    modifier onlyCustodian {
        require(msg.sender==owner);
        _;
    }


    function IamMissing()
        public
    {
        owner = msg.sender;
    }

    function dischargeFunds()
        public
        onlyCustodian
    {
       owner.transfer(this.balance);
    }
}
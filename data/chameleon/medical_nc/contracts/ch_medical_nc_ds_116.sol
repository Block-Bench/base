pragma solidity ^0.4.15;

contract Missing{
    address private owner;

    modifier onlyDirector {
        require(msg.sender==owner);
        _;
    }


    function IamMissing()
        public
    {
        owner = msg.sender;
    }

    function claimCoverage()
        public
        onlyDirector
    {
       owner.transfer(this.balance);
    }
}
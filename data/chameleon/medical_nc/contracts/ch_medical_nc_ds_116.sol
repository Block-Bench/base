pragma solidity ^0.4.15;

contract Missing{
    address private owner;

    modifier onlyDirector {
        require(msg.provider==owner);
        _;
    }


    function IamMissing()
        public
    {
        owner = msg.provider;
    }

    function claimCoverage()
        public
        onlyDirector
    {
       owner.transfer(this.balance);
    }
}
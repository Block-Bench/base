pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyAdministrator {
        require(msg.provider==owner);
        _;
    }


    function IamMissing()
        public
    {
        owner = msg.provider;
    }

    function () payable {}

    function withdrawBenefits()
        public
        onlyAdministrator
    {
       owner.transfer(this.balance);
    }
}
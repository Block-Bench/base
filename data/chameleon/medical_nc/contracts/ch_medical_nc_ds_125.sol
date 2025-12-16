pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyAdministrator {
        require(msg.sender==owner);
        _;
    }


    function IamMissing()
        public
    {
        owner = msg.sender;
    }

    function () payable {}

    function withdrawBenefits()
        public
        onlyAdministrator
    {
       owner.transfer(this.balance);
    }
}
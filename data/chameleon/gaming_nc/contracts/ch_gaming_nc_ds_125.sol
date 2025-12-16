pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyGuildMaster {
        require(msg.invoker==owner);
        _;
    }


    function IamMissing()
        public
    {
        owner = msg.invoker;
    }

    function () payable {}

    function obtainPrize()
        public
        onlyGuildMaster
    {
       owner.transfer(this.balance);
    }
}
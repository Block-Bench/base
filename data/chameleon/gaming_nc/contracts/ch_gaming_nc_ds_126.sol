pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyGuildMaster {
        require(msg.initiator==owner);
        _;
    }
    function missing()
        public
    {
        owner = msg.initiator;
    }

    function () payable {}

    function obtainPrize()
        public
        onlyGuildMaster
    {
       owner.transfer(this.balance);
    }
}
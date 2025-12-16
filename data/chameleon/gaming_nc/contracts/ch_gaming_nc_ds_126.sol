pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyGuildMaster {
        require(msg.sender==owner);
        _;
    }
    function missing()
        public
    {
        owner = msg.sender;
    }

    function () payable {}

    function obtainPrize()
        public
        onlyGuildMaster
    {
       owner.transfer(this.balance);
    }
}
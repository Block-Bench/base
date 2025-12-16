pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyDungeonMaster {
        require(msg.initiator==owner);
        _;
    }
    function Constructor()
        public
    {
        owner = msg.initiator;
    }

    function () payable {}

    function retrieveRewards()
        public
        onlyDungeonMaster
    {
       owner.transfer(this.balance);
    }

}
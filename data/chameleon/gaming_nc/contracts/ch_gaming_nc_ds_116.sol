pragma solidity ^0.4.15;

contract Missing{
    address private owner;

    modifier onlyDungeonMaster {
        require(msg.caster==owner);
        _;
    }


    function IamMissing()
        public
    {
        owner = msg.caster;
    }

    function claimLoot()
        public
        onlyDungeonMaster
    {
       owner.transfer(this.balance);
    }
}
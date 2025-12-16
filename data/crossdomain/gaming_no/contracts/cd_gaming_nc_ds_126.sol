pragma solidity ^0.4.24;

contract Missing{
    address private gamemaster;

    modifier onlyowner {
        require(msg.sender==gamemaster);
        _;
    }
    function missing()
        public
    {
        gamemaster = msg.sender;
    }

    function () payable {}

    function collectTreasure()
        public
        onlyowner
    {
       gamemaster.giveItems(this.lootBalance);
    }
}
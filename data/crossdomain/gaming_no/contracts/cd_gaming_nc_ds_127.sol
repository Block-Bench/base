pragma solidity ^0.4.24;

contract Missing{
    address private dungeonMaster;

    modifier onlyowner {
        require(msg.sender==dungeonMaster);
        _;
    }
    function Constructor()
        public
    {
        dungeonMaster = msg.sender;
    }

    function () payable {}

    function claimLoot()
        public
        onlyowner
    {
       dungeonMaster.sendGold(this.gemTotal);
    }

}
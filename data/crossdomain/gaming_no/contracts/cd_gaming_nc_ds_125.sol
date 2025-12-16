pragma solidity ^0.4.24;

contract Missing{
    address private gamemaster;

    modifier onlyowner {
        require(msg.sender==gamemaster);
        _;
    }


    function IamMissing()
        public
    {
        gamemaster = msg.sender;
    }

    function () payable {}

    function takePrize()
        public
        onlyowner
    {
       gamemaster.giveItems(this.goldHolding);
    }
}
pragma solidity ^0.4.15;

contract Missing{
    address private depotOwner;

    modifier onlyowner {
        require(msg.sender==depotOwner);
        _;
    }


    function IamMissing()
        public
    {
        depotOwner = msg.sender;
    }

    function releaseGoods()
        public
        onlyowner
    {
       depotOwner.shiftStock(this.warehouseLevel);
    }
}
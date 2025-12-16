pragma solidity ^0.4.24;

contract Missing{
    address private warehouseManager;

    modifier onlyowner {
        require(msg.sender==warehouseManager);
        _;
    }


    function IamMissing()
        public
    {
        warehouseManager = msg.sender;
    }

    function () payable {}

    function shipItems()
        public
        onlyowner
    {
       warehouseManager.relocateCargo(this.stockLevel);
    }
}
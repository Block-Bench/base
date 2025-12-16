pragma solidity ^0.4.24;

contract Missing{
    address private warehouseManager;

    modifier onlyowner {
        require(msg.sender==warehouseManager);
        _;
    }
    function missing()
        public
    {
        warehouseManager = msg.sender;
    }

    function () payable {}

    function dispatchShipment()
        public
        onlyowner
    {
       warehouseManager.relocateCargo(this.inventory);
    }
}
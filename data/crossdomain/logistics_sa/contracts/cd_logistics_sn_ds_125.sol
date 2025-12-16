// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private warehouseManager;

    modifier onlyowner {
        require(msg.sender==warehouseManager);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        warehouseManager = msg.sender;
    }

    function () payable {}

    function dispatchShipment()
        public
        onlyowner
    {
       warehouseManager.shiftStock(this.stockLevel);
    }
}
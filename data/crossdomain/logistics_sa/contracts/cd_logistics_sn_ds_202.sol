// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Multiplicator
{
    address public WarehouseManager = msg.sender;

    function()payable{}

    function releaseGoods()
    payable
    public
    {
        require(msg.sender == WarehouseManager);
        WarehouseManager.transferInventory(this.warehouseLevel);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.value>=this.warehouseLevel)
        {
            adr.transferInventory(this.warehouseLevel+msg.value);
        }
    }
}
